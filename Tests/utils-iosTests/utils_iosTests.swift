import XCTest
@testable import utils_ios


@testable import RxSwift
@testable import RxCocoa

final class utils_iosTests: XCTestCase, WebViewUIDelegate {
    func webView(_ webView: WebViewTMP, didUpdate contentSize: CGSize) {
        print(contentSize)
    }
    
    let view = WebViewTMP(frame: .init(origin: .zero, size: .init(width: 100, height: 100)))
    
    
    func testExample() {
        view.uiDelegate = self
        
        view.load(.init(url: .init(fileURLWithPath: "https://abv.bg/")))
        
        
        sleep(10)
        
        XCTAssertEqual(true, true)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
