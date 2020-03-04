import XCTest
@testable import utils_ios


@testable import RxSwift
@testable import RxCocoa

final class utils_iosTests: XCTestCase {

    func testExample() {
        // Utils.Storage.remove(key: "sieskei")
        
        print(Utils.Storage.get(for: "sieskei", default: 07))
        print(Utils.Storage.get(for: "sieskei", default: 25))
        
        
        sleep(10)
        
        XCTAssertEqual(true, true)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
