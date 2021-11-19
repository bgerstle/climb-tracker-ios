//
//  GRDB+AsyncAwait.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/18/21.
//

import Foundation
import GRDB

extension DatabaseWriter {
    func readTask<T>(_ value: @escaping (Database) throws -> T) async throws -> T {
        try await Task {
            try read(value)
        }.value
    }

    func writeTask<T>(_ updates: @escaping (Database) throws -> T) async throws -> T {
        try await Task {
            try write(updates)
        }.value
    }
}
