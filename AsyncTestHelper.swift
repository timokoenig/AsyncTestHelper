//
//  AsyncTestHelper.swift
//  AsyncTestHelper
//
//  The AsyncTestHelper helps you with executing asynchronous requests on after another within your unit tests.
//
//  Created by Timo Koenig on 07.06.18.
//  Copyright © 2018 Timo Koenig. All rights reserved.
//

import XCTest

public struct AsyncBlock {
    var block: (_ onCompletion: @escaping () -> Void) -> Void
}

public class AsyncTestHelper: NSObject {

    private static let asyncWaitTime = 3.0

    private var stack = [AsyncBlock]()
    private var testCase: XCTestCase
    private var expectation: XCTestExpectation
    private var onCompletion: (() -> Void)!

    // MARK: Lifecycle

    public init(for testCase: XCTestCase) {
        self.testCase = testCase
        self.expectation = testCase.expectation(description: "AsyncTestHelperExpectation")

        super.init()

        onCompletion = { [unowned self] in
            // Async block has been completed, start executing the next block
            self.expectation.fulfill()
            self.executeAsyncBlock()
        }
    }

    // MARK: Public Actions

    /// Add an async block to the stack
    public func add(_ asyncBlock: AsyncBlock) {
        stack.append(asyncBlock)
    }

    /// Start executing the async blocks
    public func start() {
        expectation.expectedFulfillmentCount = stack.count

        executeAsyncBlock()

        testCase.wait(for: [expectation], timeout: Double(stack.count) * AsyncTestHelper.asyncWaitTime)
    }

    // MARK: Private Helpers

    /// Execute the next async block from the stack
    private func executeAsyncBlock() {
        if stack.count == 0 { return }

        let asyncBlock = stack.removeFirst()
        asyncBlock.block(onCompletion)
    }
}
