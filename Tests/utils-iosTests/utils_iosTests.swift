import XCTest
@testable import utils_ios

final class utils_iosTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(utils_ios().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
