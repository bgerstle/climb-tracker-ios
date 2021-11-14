//
//  XCTestCase+Async.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 11/12/21.
//

import XCTest
import Foundation
import Combine

extension XCTestCase {
    func expectAsync<T>(timeout: TimeInterval = 2.0, _ f: @escaping () async throws -> T) throws -> T {
        let expectation = expectation(description: "await")
        var result: Result<T, Error>! = nil
        let cancellable = Future<T, Error> { promise in
            Task {
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
            expectation.fulfill()

        }, receiveValue: {
            result = .success($0)
        })

        waitForExpectations(timeout: timeout) { optError in
            cancellable.cancel()
            if let error = optError {
                result = .failure(error)
            }
        }

        return try result.get()
    }
}
