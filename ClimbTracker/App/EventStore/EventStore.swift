//
//  EventStore.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/11/21.
//

import Foundation
import Combine

protocol EventStore {
    func findTopic<E: PersistableTopicEvent>(id topicId: TopicIdentifier, eventType: E.Type) async throws -> AnyTopic<E>?

    func createTopic<E: PersistableTopicEvent>(id topicId: TopicIdentifier, eventType: E.Type) async throws -> AnyTopic<E>

    func namespaceEvents<E: PersistableTopicEvent>() -> TopicEventPublisher<E>

    func findOrCreateTopic<E: PersistableTopicEvent>(id topicId: TopicIdentifier, eventType: E.Type) async throws -> AnyTopic<E>
}

protocol EventEnvelopeProtocol {
    associatedtype Event

    var event: Event { get }
    var timestamp: Date { get }
}

struct EventEnvelope<T> : EventEnvelopeProtocol {
    typealias Event = T
    
    let event: T
    let timestamp: Date
}
extension EventEnvelope : Codable where T: Codable {}
extension EventEnvelope : Equatable where T: Equatable {}
extension EventEnvelope : Hashable where T: Hashable {}

protocol PersistableTopicEvent : TopicEvent {
    associatedtype PayloadType: CaseIterable, StringRawRepresentable

    var payloadType: PayloadType { get }

    func payload() throws -> Data

    init(payloadType: PayloadType, payload: Data) throws
}

extension EventEnvelope {
    func map<E>(_ transform: (T) -> E) -> EventEnvelope<E> {
        EventEnvelope<E>(event: transform(event), timestamp: timestamp)
    }
}

protocol Topic : SomeTopic {
    associatedtype Event: PersistableTopicEvent

    func write(_ eventEnvelope: EventEnvelope<Event>) async throws

    // Returns a publisher that emits prior & subsequent events written to the topic
    var eventPublisher: TopicEventPublisher<Event> { get }

    func events() async throws -> [EventEnvelope<Event>]
}

typealias TopicNamespaceIdentifier = String
typealias TopicIdentifier = String

protocol TopicEvent {
    static var namespace: TopicNamespaceIdentifier { get }
}

protocol StringRawRepresentable : RawRepresentable where RawValue == String { }

typealias TopicEventPublisher<E: PersistableTopicEvent> = AnyPublisher<EventEnvelope<E>, Never>

protocol SomeTopic {
    var id: TopicIdentifier { get }
}

struct TopicNotFound : Error {
    let namespace: TopicNamespaceIdentifier
    let id: TopicIdentifier
}

struct TopicEventTypeMismatch : Error {
    let namespace: TopicNamespaceIdentifier
    let id: TopicIdentifier
}

struct TopicAlreadyExists : Error {
    let namespace: TopicNamespaceIdentifier
    let id: TopicIdentifier
}

class AnyTopic<E: PersistableTopicEvent> : Topic {
    let id: TopicIdentifier

    typealias Event = E

    private let writeFn: (EventEnvelope<E>) async throws -> ()
    private let eventsFn: () async throws -> [EventEnvelope<E>]
    private(set) var eventPublisher: TopicEventPublisher<E>

    init<T: Topic>(_ topic: T) where T.Event == E {
        self.id = topic.id
        self.writeFn = topic.write
        self.eventsFn = topic.events
        self.eventPublisher = topic.eventPublisher
    }

    func write(_ eventEnvelope: EventEnvelope<E>) async throws {
        try await writeFn(eventEnvelope)
    }

    func events() async throws -> [EventEnvelope<E>] {
        return try await eventsFn()
    }
}
