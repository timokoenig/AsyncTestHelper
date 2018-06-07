//
//  AsyncTestHelper.swift
//
//  The AsyncTestHelper helps you with executing asynchronous requests one
//  after another within your unit tests.
//
//  Created by Timo Koenig on 07.06.18.
//
//  MIT License
//
//  Copyright (c) 2018 Timo Koenig
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
