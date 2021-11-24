//
//  PersistentEventStore.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/18/21.
//

import Foundation
import GRDB
import Combine

class PersistentEventStore : EventStore {
    let db: DatabaseWriter

    init(db: DatabaseWriter) throws {
        self.db = db
    }

    func findTopic<E>(id topicId: TopicIdentifier, eventType: E.Type) async throws -> AnyTopic<E>? where E : PersistableTopicEvent {
        try await db.readTask { db in
            try DBTopic.fetchOne(db, id: topicId)
        }.map { $0.toAnyTopic(db: db) }
    }

    func createTopic<E>(id topicId: TopicIdentifier, eventType: E.Type) async throws -> AnyTopic<E> where E : PersistableTopicEvent {
        let dbTopic = DBTopic(id: topicId, namespace: E.namespace)
        try await db.writeTask { db in
            try dbTopic.insert(db)
        }
        return dbTopic.toAnyTopic(db: db)
    }

    func namespaceEvents<E>() -> TopicEventPublisher<E> where E : PersistableTopicEvent {
        let topicAlias = TableAlias()
        return ValueObservation
            .trackingConstantRegion(
                DBEvent
                    .joining(required: DBEvent.topicRelation.aliased(topicAlias))
                    .filter(topicAlias[Column("namespace")] == E.namespace)
                    // !!!: must order by id to ensure new events are at end of result set
                    .order(Column("id").asc)
                    .fetchAll)
            .publisher(in: db, scheduling: .async(onQueue: DispatchQueue(label: "dbnamespace-\(E.namespace)")))
            .logPublisher
            .mapToEvents()
            // FIXME: refactor topic protocol to allow failures
            .assertNoFailure()
            .eraseToAnyPublisher()

    }

    func findOrCreateTopic<E>(id topicId: TopicIdentifier, eventType: E.Type) async throws -> AnyTopic<E> where E : PersistableTopicEvent {
        let dbTopic = try await db.writeTask { db -> DBTopic in
            if let existingTopic = try DBTopic.fetchOne(db, id: topicId) {
                return existingTopic
            }
            let dbTopic = DBTopic(id: topicId, namespace: E.namespace)
            try dbTopic.insert(db)
            return dbTopic
        }
        return dbTopic.toAnyTopic(db: db)
    }
}

extension DatabaseMigrator {
    mutating func setupEventStoreMigrations() {
        registerMigration("eventStore-v1") { db in
            try db.create(table: "topics") { t in
                t.column("namespace", .text).notNull().indexed()
                t.column("id", .text).notNull().unique().indexed()
                t.primaryKey(["id"])
            }

            try db.create(table: "events") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("topicId")
                    .notNull()
                    .indexed()
                    .references("topics", onDelete: .cascade)
                t.column("event", .text).notNull()
                t.column(sql: "timestamp DATETIME ")
                t.column("payload", .blob).notNull()
            }
        }
    }
}


struct DBTopic : Hashable, Codable, FetchableRecord, PersistableRecord, Identifiable {
    typealias ID = TopicIdentifier

    static var databaseTableName: String { "topics" }

    let id: TopicIdentifier
    let namespace: TopicNamespaceIdentifier

    static let eventsRelation = hasMany(DBEvent.self)

    var events: QueryInterfaceRequest<DBEvent> {
        request(for: DBTopic.eventsRelation)
    }

    func toAnyTopic<T: PersistableTopicEvent>(db: DatabaseWriter) -> AnyTopic<T> {
        AnyTopic(PersistentEventTopic(dbTopic: self, db: db))
    }
}

struct DBEvent : Hashable, Codable, FetchableRecord, PersistableRecord {
    var id: Int64? = nil
    let topicId: TopicIdentifier
    let event: String
    let payload: Data
    let timestamp: Date

    static var databaseTableName: String { "events" }

    static let topicRelation = belongsTo(DBTopic.self)

    var topic: QueryInterfaceRequest<DBTopic> {
        request(for: DBEvent.topicRelation)
    }

    init<E: PersistableTopicEvent>(topicId: TopicIdentifier, envelope: EventEnvelope<E>) throws {
        self.topicId = topicId
        self.event = envelope.event.payloadType.rawValue
        self.timestamp = envelope.timestamp
        self.payload = try envelope.event.payload()
    }
}

extension EventEnvelope where T: PersistableTopicEvent {
    init(dbEvent: DBEvent) throws {
        self.timestamp = dbEvent.timestamp
        guard let payloadType = T.PayloadType(rawValue: dbEvent.event) else {
            throw UnknownTopicEventPayloadType(rawValue: dbEvent.event, type: T.self)
        }
        self.event = try T(payloadType: payloadType, payload: dbEvent.payload)
    }
}

struct UnknownTopicEventPayloadType<T> : Error {
    let rawValue: String
    let type: T.Type
}

class PersistentEventTopic<E: PersistableTopicEvent> : Topic {
    typealias Event = E

    let dbTopic: DBTopic
    let db: DatabaseWriter
    private let sharedObservation: SharedValueObservation<[DBEvent]>

    nonisolated var id: TopicIdentifier {
        dbTopic.id
    }

    init(dbTopic: DBTopic, db: DatabaseWriter) {
        self.dbTopic = dbTopic
        self.db = db

        self.sharedObservation = ValueObservation
            .trackingConstantRegion(dbTopic.events.fetchAll)
            .shared(in: db, scheduling: .async(onQueue: DispatchQueue(label: "dbtopic-\(dbTopic.namespace)-\(dbTopic.id)")))
    }

    func write(_ eventEnvelope: EventEnvelope<Event>) async throws {
        // TODO: how to guarantee "single writer" for topics?
        try await db.writeTask { db in
            try DBEvent(topicId: self.dbTopic.id, envelope: eventEnvelope).insert(db)
        }
    }

    // Returns a publisher that emits prior & subsequent events written to the topic
    var eventPublisher: AnyPublisher<EventEnvelope<Event>, Never> {
        sharedObservation
            .publisher()
            .logPublisher
            .mapToEvents()
            // FIXME: refactor topic protocol to allow failures
            .assertNoFailure()
            .eraseToAnyPublisher()
    }

    func events() async throws -> [EventEnvelope<Event>] {
        try await db.readTask { db in
            try self.dbTopic.events.fetchAll(db).map { dbEvent in
                try EventEnvelope<E>(dbEvent: dbEvent)
            }
        }
    }
}

extension Publisher where Output == DBEvent {
    func mapToEvents<E: PersistableTopicEvent>() -> AnyPublisher<EventEnvelope<E>, Error> {
        tryMap { dbEvent in
            try EventEnvelope<E>(dbEvent: dbEvent)
        }
        .eraseToAnyPublisher()
    }
}
