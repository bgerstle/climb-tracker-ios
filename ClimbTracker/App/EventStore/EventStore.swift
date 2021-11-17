//
//  EventStore.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/11/21.
//

import Foundation
import Combine

protocol TopicEvent {
    static var namespace: String { get }
}

struct EventEnvelope<T> {
    let event: T
    let timestamp: Date
}
extension EventEnvelope : Equatable where T: Equatable {}
extension EventEnvelope : Hashable where T: Hashable {}

typealias TopicEventPublisher<E: TopicEvent> = AnyPublisher<EventEnvelope<E>, Never>

protocol EventStore {
    func findTopic<E: TopicEvent>(id topicId: TopicIdentifier, eventType: E.Type) async throws -> AnyTopic<E>?

    func createTopic<E: TopicEvent>(id topicId: TopicIdentifier, eventType: E.Type) async throws -> AnyTopic<E>

    func namespaceEvents<E: TopicEvent>() -> TopicEventPublisher<E>

    func findOrCreateTopic<E: TopicEvent>(id topicId: TopicIdentifier, eventType: E.Type) async throws -> AnyTopic<E>
}

protocol SomeTopic {
    var id: TopicIdentifier { get }
}

protocol Topic : SomeTopic {
    associatedtype Event: TopicEvent

    func write(_ eventEnvelope: EventEnvelope<Event>) async throws

    // Returns a publisher that emits prior & subsequent events written to the topic
    var eventPublisher: TopicEventPublisher<Event> { get }

    func events() async throws -> [EventEnvelope<Event>]
}

typealias TopicNamespaceIdentifier = String
typealias TopicIdentifier = String

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

class AnyTopic<E: TopicEvent> : Topic {
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
