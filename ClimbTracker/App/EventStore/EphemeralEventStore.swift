//
//  EphemeralEventStore.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/17/21.
//

import Foundation
import Combine

actor EphemeralEventStore : EventStore {
    typealias TopicNamespace = [SomeTopic]
    typealias TopicNamespaceMap = [TopicNamespaceIdentifier: CurrentValueSubject<TopicNamespace, Never>]

    var namespaces = CurrentValueSubject<TopicNamespaceMap, Never>([:])

    func findTopic<E: PersistableTopicEvent>(id topicId: TopicIdentifier, eventType: E.Type) async throws -> AnyTopic<E>? {
        return try _findTopic(id: topicId, eventType: eventType)
    }

    func findOrCreateTopic<E: PersistableTopicEvent>(id topicId: TopicIdentifier, eventType: E.Type) async throws -> AnyTopic<E> {
        guard let existingTopic = try _findTopic(id: topicId, eventType: eventType) else {
            return try _createTopic(id: topicId, eventType: eventType)
        }
        return existingTopic
    }

    func createTopic<E>(id topicId: TopicIdentifier, eventType: E.Type) async throws -> AnyTopic<E> where E : PersistableTopicEvent {
        return try _createTopic(id: topicId, eventType: eventType)
    }

    // MARK: Declare synchronous methods so they can be easily composed without introducing suspension points. See:
    // https://github.com/apple/swift-evolution/blob/main/proposals/0306-actors.md#interleaving-execution-with-reentrant-actors
    /* which states:

     The potential for interleaved execution at suspension points is the primary reason for the requirement that every suspension point be marked by await in the source code, even though await itself has no semantic effect. It is an indicator that any shared state might change across the await, so one should avoid breaking invariants across an await, or otherwise depending on the state "before" to be identical to the state "after".

     Generally speaking, the easiest way to avoid breaking invariants across an await is to encapsulate state updates in synchronous actor functions.
     */
    private func _findTopic<E: PersistableTopicEvent>(id topicId: TopicIdentifier, eventType: E.Type) throws -> AnyTopic<E>? {
        guard let namespace = namespaces.value[E.namespace],
              let someTopic = namespace.value.first(where: { $0.id == topicId }) else {
                  return nil
        }
        guard let topic = someTopic as? EphemeralTopic<E> else {
            throw TopicEventTypeMismatch(namespace: E.namespace, id: topicId)
        }

        return AnyTopic(topic)
    }

    private func _createTopic<E>(id topicId: TopicIdentifier, eventType: E.Type) throws -> AnyTopic<E> where E : PersistableTopicEvent {
        let namespace = namespaces.value[E.namespace, default: CurrentValueSubject(TopicNamespace())]

        if try _findTopic(id: topicId, eventType: eventType) != nil {
            throw TopicAlreadyExists(namespace: E.namespace, id: topicId)
        }

        let topic = EphemeralTopic<E>(id: topicId)
        namespace.value.append(topic)

        namespaces.value[E.namespace] = namespace

        return AnyTopic(topic)
    }

    func namespaceEventsAsync<E>() -> TopicEventPublisher<E> {
        // filter to desired namespace
        let matchingNamespace = namespaces.filter { namespaces in
            namespaces[E.namespace] != nil
        }
            // only get first event with a matching namespace (indicating it has been created)
            .first()
            // extract matching namespace from map
            .map { $0[E.namespace]! },
            // flatten to stream of topics in that namespace
            elementsInMatchingNamespace = matchingNamespace.flatMap { namespace in
                namespace.logPublisher
            },
            // extract topics from element tuple
            topicsInMatchingNamespace = elementsInMatchingNamespace.map {
                $0 as! EphemeralTopic<E>
            },
            // flatten to stream of events in topics in that namesapce
            eventsFromTopicsInMatchingNamespace = topicsInMatchingNamespace.flatMap { topic in
                topic.eventPublisher
            }
        // erase to match return type
        return eventsFromTopicsInMatchingNamespace.eraseToAnyPublisher()
    }

    nonisolated func namespaceEvents<E>() -> TopicEventPublisher<E> {
        Future { promise in
            Task(priority: Task.currentPriority) {
                promise(.success(await self.namespaceEventsAsync()))
            }
        }
        .flatMap { $0 }
        .eraseToAnyPublisher()
    }
}

actor EphemeralTopic<E: PersistableTopicEvent> : Topic {
    typealias Event = E

    let id: TopicIdentifier

    @Published
    private var events: [EventEnvelope<E>] = []

    init(id: TopicIdentifier) {
        self.id = id
    }

    func write(_ eventEnvelope: EventEnvelope<E>) async throws {
        events.append(eventEnvelope)
    }

    nonisolated var eventPublisher: TopicEventPublisher<E> {
        Future { promise in
            // need to use "detached" to avoid contending with readAsync actor isolation
            Task {
                promise(.success(await self.$events.logPublisher))
            }
        }
        // convert(/flatten) "Future" publisher into underlying event publisher
        .flatMap { $0 }
        .eraseToAnyPublisher()
    }

    func events() async throws -> [EventEnvelope<E>] { events }

    typealias EventType = E
}
