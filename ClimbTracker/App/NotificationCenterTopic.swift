//
//  NotificationCenterTopic.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation
import Combine

protocol NotificationCenterTopic: Topic {
    static var notificationName: Notification.Name { get }
}

extension NotificationCenter {
    func publisher<T: NotificationCenterTopic>(topic: T.Type) -> Publishers.Map<NotificationCenter.Publisher, EventEnvelope<T.EventType>> {
        return publisher(for: topic.notificationName).map { notification in
            return notification.object as! EventEnvelope<T.EventType>
        }
    }

    func subject<T: NotificationCenterTopic>(topic: T.Type) -> (PassthroughSubject<EventEnvelope<T.EventType>, Never>, AnyCancellable) {
        let subject = PassthroughSubject<EventEnvelope<T.EventType>, Never>()
        let cancellable = subject.sink {
            self.post(name: topic.notificationName, object: $0)
        }
        return (subject, cancellable)
    }
}
