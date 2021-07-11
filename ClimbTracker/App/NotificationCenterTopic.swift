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

extension NotificationCenter.Publisher {
    func convertToEvents<T: NotificationCenterTopic>(on topic: T.Type) -> some Combine.Publisher
    {
        return map { notification in
            return notification.object as! EventEnvelope<T.Type>
        }
    }

}
extension NotificationCenter {
    func publisher<T: NotificationCenterTopic>(topic: T.Type) -> some Combine.Publisher {
        return publisher(for: T.notificationName).convertToEvents(on: topic)
    }
}
