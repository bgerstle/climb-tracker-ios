//
//  GRDB+AsyncAwait.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/18/21.
//

import Foundation
import Combine
import GRDB

extension DatabaseWriter {
    func readTask<T>(_ value: @escaping (Database) throws -> T) async throws -> T {
        try await Future { promise in
            self.asyncRead { dbResult in
                promise(dbResult.flatMap { db in
                    Result { try value(db) }
                })
            }
        }.value
    }

    func writeTask<T>(_ updates: @escaping (Database) throws -> T) async throws -> T {
        try await Future { promise in
            self.asyncWrite(updates, completion: { _, result in promise(result) })
        }.value
    }
}
