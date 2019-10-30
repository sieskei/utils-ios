import XCTest
@testable import utils_ios

class ObjA {
    deinit {
        print("ObjA deinited ...")
    }
}

class ObjB {
    deinit {
        print("ObjB deinited ...")
    }
}

extension ObjA: AssociatedObjectCompatible {
    
}

final class utils_iosTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        var objs = [ObjA]()
        for index in 0 ..< 1_000_000 {
            objs.append(ObjA())
        }
        
        for index in 0 ..< 1_000_000 {
            let obj = objs[index]
            obj.set(value: ObjB(), for: "objb")
        }
        
        objs.forEach {
            print($0.get(for: "objb", default: ObjB()))
        }
        
        XCTAssertEqual(true, true)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
