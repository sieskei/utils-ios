import XCTest
@testable import utils_ios


import RxSwift

class TestModel: RxMultipleTimesDecodable {
    let name: String
    
    init(_ name: String) {
        self.name = name
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        self.name = "ivan"
        try super.init(from: decoder)
    }
}

class TestView: UIView, RxModelCompatible {
    typealias M = TestModel
}

final class utils_iosTests: XCTestCase {
    private let disposeBag = DisposeBag()
    
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        let view1 = TestView(frame: .zero)
        view1.rx.decode.subscribe(onNext: { model in
            print("decode...")
            model.onValue { print($0.name) }
        }).disposed(by: disposeBag)
        
        let view2 = TestView(frame: .zero)
        view2.rx.decode.subscribe(onNext: { model in
            print("decode...")
            model.onValue { print($0.name) }
        }).disposed(by: disposeBag)
        
        
        
        

        
        
        
        
        
        let model1: TestModel = .init("miroslav")
        view1.model = .value(model1)
        
        let model2: TestModel = .init("yozov")
        view2.model = .value(model2)
        
        
        model1.simulateDecode()
        model2.simulateDecode()
        
        
        
        
        
        XCTAssertEqual(true, true)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
