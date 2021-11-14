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

protocol EventStore {
    func findTopic<E: TopicEvent>(id topicId: TopicIdentifier, eventType: E.Type) async throws -> AnyTopic<E>?

    func createTopic<E: TopicEvent>(id topicId: TopicIdentifier, eventType: E.Type) async throws -> AnyTopic<E>

    func namespaceEvents<E: TopicEvent>() -> AnyPublisher<EventEnvelope<E>, Never>
}

protocol SomeTopic {
    var id: TopicIdentifier { get }
}

protocol Topic : SomeTopic {
    associatedtype Event: TopicEvent

    func write(_ eventEnvelope: EventEnvelope<Event>) async throws

    // Returns a publisher that emits prior & subsequent events written to the topic
    func read() -> AnyPublisher<EventEnvelope<Event>, Never>
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
    private let readFn: () -> AnyPublisher<EventEnvelope<E>, Never>

    init<T: Topic>(_ topic: T) where T.Event == E {
        self.id = topic.id
        self.writeFn = topic.write
        self.readFn = topic.read
    }

    func write(_ eventEnvelope: EventEnvelope<E>) async throws {
        try await writeFn(eventEnvelope)
    }

    func read() -> AnyPublisher<EventEnvelope<E>, Never> {
        readFn()
    }
}

actor EphemeralEventStore : EventStore {
    typealias TopicNamespace = [SomeTopic]
    typealias TopicNamespaceMap = [TopicNamespaceIdentifier: CurrentValueSubject<TopicNamespace, Never>]

    var namespaces = CurrentValueSubject<TopicNamespaceMap, Never>([:])

    func findTopic<E: TopicEvent>(id topicId: TopicIdentifier, eventType: E.Type) async throws -> AnyTopic<E>? {
        guard let namespace = namespaces.value[E.namespace],
              let someTopic = namespace.value.first(where: { $0.id == topicId }) else {
                  return nil
        }
        guard let topic = someTopic as? EphemeralTopic<E> else {
            throw TopicEventTypeMismatch(namespace: E.namespace, id: topicId)
        }

        return AnyTopic(topic)
    }

    func createTopic<E>(id topicId: TopicIdentifier, eventType: E.Type) async throws -> AnyTopic<E> where E : TopicEvent {
        let namespace = namespaces.value[E.namespace, default: CurrentValueSubject(TopicNamespace())]

        if namespace.value.first(where: { $0.id == topicId }) != nil {
            throw TopicAlreadyExists(namespace: E.namespace, id: topicId)
        }

        let topic = EphemeralTopic<E>(id: topicId)
        namespace.value.append(topic)

        namespaces.value[E.namespace] = namespace

        return AnyTopic(topic)
    }

    func namespaceEventsAsync<E>() -> AnyPublisher<EventEnvelope<E>, Never> where E : TopicEvent {
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
                topic.read()
//                Future { promise in
//                    Task.detached(priority: Task.currentPriority) {
//                        // I don't know why, but using read() here causes race conditions 😱
//                        // So we do the Future/Task dance
//                        promise(.success(await topic.readAsync()))
//                    }
//                }.flatMap { $0 }
            }
        // erase to match return type
        return eventsFromTopicsInMatchingNamespace.eraseToAnyPublisher()
    }

    nonisolated func namespaceEvents<E>() -> AnyPublisher<EventEnvelope<E>, Never> where E : TopicEvent {
        Future { promise in
            Task.detached(priority: Task.currentPriority) {
                promise(.success(await self.namespaceEventsAsync()))
            }
        }
        .flatMap { $0 }
        .eraseToAnyPublisher()
    }
}

actor EphemeralTopic<E: TopicEvent> : Topic {
    typealias Event = E

    typealias EventPublisher = AnyPublisher<EventEnvelope<E>, Never>

    let id: TopicIdentifier

    @Published
    private var events: [EventEnvelope<E>] = []

    init(id: TopicIdentifier) {
        self.id = id
    }

    func write(_ eventEnvelope: EventEnvelope<E>) async throws {
        events.append(eventEnvelope)
    }

    nonisolated func read() -> EventPublisher {
        Future { promise in
            // need to use "detached" to avoid contending with readAsync actor isolation
            Task.detached {
                promise(.success(await self.readAsync()))
            }
        }
        // convert(/flatten) "Future" publisher into underlying event publisher
        .flatMap { $0 }
        .eraseToAnyPublisher()
    }

    func readAsync() -> EventPublisher {
        // use a cursor emit each new event, starting with current events
        return $events.logPublisher
    }

    typealias EventType = E
}

extension Publisher where Output: Collection, Failure == Never {
    // don't use on lists that are subject to operations other than append
    var logPublisher: AnyPublisher<Output.Element, Never> {
        // assumes elements are only appended so that new ones are always at the end,
        // which implies that the publisher only signals when new elements are added
        var offset = 0
        return flatMap { updatedElements -> AnyPublisher<Output.Element, Never> in
                let newElements = updatedElements.dropFirst(offset)
                offset += newElements.count
            return Publishers.Sequence(sequence: newElements).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
