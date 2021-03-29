import XCTest
@testable import UNIDocumentCRUD

final class UNIDocumentCRUDTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(UNIDocumentCRUD().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
