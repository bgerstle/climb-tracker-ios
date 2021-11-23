//
//  XCTestCase+Async.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 11/12/21.
//

import XCTest
import Foundation
import Combine

struct ExpectAsyncUnfulfilled : Error {}

extension XCTestCase {
    func expectAsync<T>(timeout: TimeInterval = 2.0,
                        description: String = "",
                        _ f: @escaping () async throws -> T) throws -> T {
        let futureExpectation = expectation(description: description)
        var result: Result<T, Error> = Result.failure(ExpectAsyncUnfulfilled())
        let cancellable = Future<T, Error> { promise in
            Task.detached {
                do {
                    let value = try await f()
                    promise(.success(value))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .sink(receiveCompletion: { futureResult in
            if case .failure(let error) = futureResult {
                result = .failure(error)
            }
            futureExpectation.fulfill()

        }, receiveValue: {
            result = .success($0)
        })

        wait(for: [futureExpectation], timeout: timeout)

        cancellable.cancel()

        return try result.get()
    }
}
