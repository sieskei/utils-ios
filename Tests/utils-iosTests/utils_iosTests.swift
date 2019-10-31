import XCTest
@testable import utils_ios


import RxSwift

class TestModel: RxMultipleTimesDecodable {
    deinit {
        print("deinit")
    }
}



final class utils_iosTests: XCTestCase {
    private let disposeBag = DisposeBag()
    
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        let testAAA = TestModel()
        testAAA.rx.decode.subscribe(onNext: { model in
            print("called ...")
        }).disposed(by: disposeBag)

        
        
        XCTAssertEqual(true, true)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
