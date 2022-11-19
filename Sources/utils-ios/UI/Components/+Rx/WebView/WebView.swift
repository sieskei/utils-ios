//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 21.06.22.
//

import UIKit
import WebKit
import RxSwift

extension Utils.UI {
    open class WebView: Utils.UI.SimpleWebView {
        public enum BodySize: Equatable {
            case ready(CGSize)
            case sensor(CGSize)
            
            public var value: CGSize {
                switch self {
                case .ready(let s), .sensor(let s):
                    return s
                }
            }
        }
        
        fileprivate var navigationDisposeBag: DisposeBag = .init()
        
        @RxProperty
        public private (set) var isReady: Bool = false
        
        @RxProperty
        public private (set) var bodySize: BodySize = .ready(.zero) {
            didSet {
                bodySizeValue = bodySize.value
            }
        }
        
        @objc
        public private (set) dynamic lazy var bodySizeValue: CGSize = bodySize.value
        
        public let resizeSensor: Bool
        
        public convenience init(configuration: WKWebViewConfiguration = WKWebViewConfiguration(), resizeSensor flag: Bool = true) {
            configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
            self.init(frame: .zero, configuration: configuration, resizeSensor: flag)
        }
        
        public convenience init(frame: CGRect, resizeSensor flag: Bool = true) {
            let configuration = WKWebViewConfiguration()
            configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
            self.init(frame: frame, configuration: configuration, resizeSensor: flag)
        }
        
        public init(frame: CGRect, configuration: WKWebViewConfiguration, resizeSensor flag: Bool = true) {
            resizeSensor = flag
            super.init(frame: frame, configuration: configuration)
        }
        
        public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
            resizeSensor = true
            super.init(frame: frame, configuration: configuration)
        }
        
        public required init?(coder: NSCoder) {
            resizeSensor = true
            super.init(coder: coder)
        }
        
        // ---------------
        // MARK: Load API.
        // ---------------
        
        @discardableResult
        private func prepare(navigation: WKNavigation?) -> WKNavigation? {
            navigation ~> { navi in
                rx.didFinishLoad
                    .filter { $0 == navi }
                    .do(with: self, onNext: { this, _ in
                        this.isReady = true
                    })
                    .withUnretained(self)
                    .flatMapLatest { this, _ -> Observable<CGSize> in
                        this.rx.evaluateJavaScript(
                        """
                            (function () {
                                var rect = document.body.getBoundingClientRect();
                                return {
                                    width: Math.round(rect.width),
                                    height: Math.round(rect.height)
                                }
                            })();
                        """
                        )
                        .map { (m: Dictionary<String, CGFloat>) -> CGSize in
                            var size: CGSize = .zero
                            size.height = m["height"] ?? .zero
                            size.width = m["width"] ?? .zero
                            return size
                        }
                        .asObservable()
                    }
                    .map { .ready($0) }
                    .bind(to: $bodySize.value)
                    .disposed(by: navigationDisposeBag)
            }
        }
        
        @discardableResult
        open override func load(_ request: URLRequest) -> WKNavigation? {
            reset()
            return prepare(navigation: super.load(request))
        }
        
        @discardableResult
        open override func loadFileURL(_ URL: URL, allowingReadAccessTo readAccessURL: URL) -> WKNavigation? {
            reset()
            return prepare(navigation: super.loadFileURL(URL, allowingReadAccessTo: readAccessURL))
        }
        
        @discardableResult
        open override func load(_ data: Data, mimeType MIMEType: String, characterEncodingName: String, baseURL: URL) -> WKNavigation? {
            reset()
            return prepare(navigation: super.load(data, mimeType: MIMEType, characterEncodingName: characterEncodingName, baseURL: baseURL))
        }
        
        @discardableResult
        open override func loadHTMLString(_ string: String, baseURL: URL?) -> WKNavigation? {
            reset()
            return prepare(navigation: super.loadHTMLString(string, baseURL: baseURL))
        }
        
        open func reset() {
            isReady = false
            bodySize = .ready(.zero)
            navigationDisposeBag = .init()
        }
        
        deinit {
            print(self, "deinit ...")
        }
    }
}

extension Utils.UI.WebView {
    @objc
    open dynamic override func prepareConfiguration() {
        super.prepareConfiguration()
        
        let ucc = configuration.userContentController
        
        // MARK: Body resize sensor
        if resizeSensor {
            ucc.addScriptMessageHandler(name: "bodysize") { [weak self] message in
                if let this = self, let size = message.size {
                    this.bodySize = .sensor(size)
                }
            }
            
            // resize sensor
            ucc.addUserScript(.init(source: ResizeSensor.source, injectionTime: .atDocumentStart, forMainFrameOnly: true))
            
            // body resize notifier
            ucc.addUserScript(.init(source:
                """
                    new ResizeSensor(document.body, function() {
                        var rect = document.body.getBoundingClientRect();
                        window.webkit.messageHandlers.bodysize.postMessage({ width: Math.round(rect.width), height: Math.round(rect.height) });
                    });
                """, injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        }
    }
}

// MARK: Utilities
fileprivate extension WKScriptMessage {
    var size: CGSize? {
        if let sizeMap = body as? [String: CGFloat],
           let w = sizeMap["width"], w.isFinite,
           let h = sizeMap["height"], h.isFinite {
            return .init(width: w, height: h)
        } else {
            return nil
        }
    }
}
