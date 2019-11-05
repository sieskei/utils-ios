import XCTest
@testable import utils_ios


import RxSwift

class TestModel: RxMultipleTimesDecodable {
    let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    required init(from decoder: Decoder) throws {
        self.name = "ivan"
    }
    
    func decode(from decoder: Decoder) throws {
    }
    
    deinit {
        print("deinit \(name)")
    }
}

extension URL: Endpoint {
    public func asURLRequest() throws -> URLRequest {
        return URLRequest(url: self)
    }
}

extension TestModel: RxRemoteCompatible {
    var remoteEndpoint: Endpoint {
        return URL(string: "https://www.mocky.io/v2/5185415ba171ea3a00704eed")!
    }
}

extension TestModel: RxRemotePagableCompatible {
    var remoteHasNextPage: Bool {
        return true
    }
    
    var remoteNextPageEndpoint: Endpoint {
        return URL(string: "https://www.mocky.io/v2/5185415ba171ea3a00704eed")!
    }
}

class TestView: UIView, RxModelCompatible {
    typealias M = TestModel
}

let view1 = TestView(frame: .zero)
let view2 = TestView(frame: .zero)

var model1: TestModel? = .init("miroslav")
var model2: TestModel? = .init("yozov")



final class utils_iosTests: XCTestCase {
    private let disposeBag = DisposeBag()
    
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
       
        view1.rx.decode.subscribe(onNext: { model in
            print("decode...")
            model.onValue { print($0.name) }
        }).disposed(by: disposeBag)


        view2.rx.decode.subscribe(onNext: { model in
            print("decode...")
            model.onValue { print($0.name) }
        }).disposed(by: disposeBag)


//        view1.model = .init(model1)
//        view2.model = .init(model2)

        for _ in 1 ..< 2 {
            model1?.reinit()
            model2?.nextPage()
        }

        model1?.rx.remoteState.subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)

        model1 = nil
        model2 = nil

        sleep(10)
        
        
        
        
        XCTAssertEqual(true, true)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
