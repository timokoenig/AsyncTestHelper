# AsyncTestHelper
The AsyncTestHelper helps you with executing asynchronous requests on after another within your unit tests.

## Example

```swift
/// Test: Create a new model
let createTest = AsyncBlock { [unowned self] (onCompletion) in
    let model = Model()

    self.networkService.create(model) { result in
        if let error = result.error {
            XCTFail(error.localizedDescription)
            return
        }

        onCompletion()
    }
}

/// Fetch all models
let fetchAllTest = AsyncBlock { [unowned self] (onCompletion) in
    self.networkService.fetchAll { result in
        guard let value = result.value else {
            XCTFail(result.error?.localizedDescription ?? "Something went wrong")
            return
        }

        XCTAssertEqual(value.count, 1)

        onCompletion()
    }
}

/// Create the AsyncTestHelper for this XCTestCase class
let helper = AsyncTestHelper(for: self)

/// Add async blocks that should be executed
helper.add(createTest)
helper.add(fetchAllTest)

/// Start the tests
helper.start()
```
