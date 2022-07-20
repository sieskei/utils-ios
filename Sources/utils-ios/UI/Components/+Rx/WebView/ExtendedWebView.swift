//
//  WebView.swift
//  
//
//  Created by Miroslav Yozov on 15.01.20.
//

import UIKit
import WebKit

import RxSwift
import RxSwiftExt
import RxCocoa

extension Utils.UI {
    open class ExtendedWebView: WKWebView {
        private let disposeBag = DisposeBag()
        
        @RxProperty
        private var isReady: Bool = false {
            didSet {
                guard isReady else {
                    return
                }
                
                /*
                 Set body margins and display.
                 */
                evaluateJavaScript(
                    """
                        \(Margin.top(headerContainerView.bounds.height).script(for: scrollView.zoomScale))
                        \(Margin.bottom(footerContainerView.bounds.height).script(for: scrollView.zoomScale))
                        document.body.style.display = "block";
                    """
                )
            }
        }
        
        private lazy var zoomScale: Observable<CGFloat> = {
            scrollView.rx.didZoom
                .withUnretained(self)
                .map { this, _ in this.scrollView.zoomScale }
                .startWith(scrollView.zoomScale)
                .map { round($0 * 1000) / 1000.0 }
                .distinctUntilChanged()
        }()
        
        @RxProperty
        public var freezeHeaderBounds: Bool = false
        
        public private (set) lazy var headerContainerView: UIView = {
            headerContainerViewClass.init(frame: .init(origin: .zero, size: .init(width: bounds.width, height: 0)))
        }()
        
        public private (set) lazy var footerContainerView: UIView = {
            footerContainerViewClass.init(frame: .init(origin: .zero, size: .init(width: bounds.width, height: 0)))
        }()
        
        open var headerContainerViewClass: UIView.Type {
            UIView.self
        }
        
        open var footerContainerViewClass: UIView.Type {
            UIView.self
        }
        
        open var headerTopConstraintConstant: Observable<CGFloat> {
            /*
             Follow vertical scroll content offset.
            */
            scrollView.rx.contentOffset.map { -$0.y }
        }
        
        open var footerTopConstraintConstant: Observable<CGFloat> {
            /*
             Follow body size + scale (see top constraint).
            */
            Observable.combineLatest($bodySize.height, zoomScale).map { $0 * $1 }
        }
        
        @RxProperty
        public private (set) var bodySize: CGSize = .zero
        
        public convenience init(configuration: WKWebViewConfiguration = WKWebViewConfiguration()) {
            configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
            self.init(frame: .zero, configuration: configuration)
        }
        
        public convenience init(frame: CGRect) {
            let configuration = WKWebViewConfiguration()
            configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
            self.init(frame: frame, configuration: configuration)
        }
        
        public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
            super.init(frame: frame, configuration: configuration)
            prepare()
        }
        
        public required init?(coder: NSCoder) {
            super.init(coder: coder)
            prepare()
        }
        
        open func prepare() {
            isOpaque = false
            backgroundColor = .clear
            scrollView.backgroundColor = .clear
            
            prepareHeaderContainerView()
            prepareFooterContainerView()
            
            prepareConfiguration()
            prepareRx()
        }
        
        open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            headerContainerView.hitTest(convert(point, to: headerContainerView), with: event) ??
                footerContainerView.hitTest(convert(point, to: footerContainerView), with: event) ??
                super.hitTest(point, with: event)
        }
        
        
        // ---------------
        // MARK: Load API.
        // ---------------
        
        @discardableResult
        open override func load(_ request: URLRequest) -> WKNavigation? {
            isReady = false
            return super.load(request)
        }
        
        @discardableResult
        open override func loadFileURL(_ URL: URL, allowingReadAccessTo readAccessURL: URL) -> WKNavigation? {
            isReady = false
            return super.loadFileURL(URL, allowingReadAccessTo: readAccessURL)
        }
        
        @discardableResult
        open override func load(_ data: Data, mimeType MIMEType: String, characterEncodingName: String, baseURL: URL) -> WKNavigation? {
            isReady = false
            return super.load(data, mimeType: MIMEType, characterEncodingName: characterEncodingName, baseURL: baseURL)
        }
        
        @discardableResult
        open override func loadHTMLString(_ string: String, baseURL: URL?) -> WKNavigation? {
            isReady = false
            return super.loadHTMLString(string, baseURL: baseURL)
        }
        
        deinit {
            Utils.Log.debug(self)
        }
    }
}

// -------------------------------------------
// MARK: Prepeare header and footer containrs.
// -------------------------------------------
fileprivate extension Utils.UI.ExtendedWebView {
    func prepareHeaderContainerView() {
        let view = headerContainerView
        
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.insertSubview(view, at: 0)
        
        // dynamic top constraint
        let topConstraint = view.topAnchor.constraint(equalTo: topAnchor)
        headerTopConstraintConstant
            .distinctUntilChanged()
            .bind(to: topConstraint.rx.constant)
            .disposed(by: disposeBag)
        
        // static constraints
        NSLayoutConstraint.activate([
            topConstraint,
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    func prepareFooterContainerView() {
        let view = footerContainerView
        
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.insertSubview(view, at: 1)
        
        // dynamic top constraint
        let topConstraint = view.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor)
        footerTopConstraintConstant
            .distinctUntilChanged()
            .bind(to: topConstraint.rx.constant)
            .disposed(by: disposeBag)
        
        // static constraints
        NSLayoutConstraint.activate([
            topConstraint,
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}



// -----------------------------
// MARK: Prepeare configuration.
// -----------------------------
extension Utils.UI.ExtendedWebView {
    private static var messageLogging = "logging"
    private static var messageReady = "ready"
    private static var messageBodySize = "bodysize"
    
    private enum Margin: Equatable {
        case top(CGFloat)
        case bottom(CGFloat)
        
        func script(for scale: CGFloat) -> String {
            switch self {
            case .top(let v):
                return "document.body.style.setProperty(\"margin-top\", \"\(v / scale)px\", \"important\")"
            case .bottom(let v):
                return "document.body.style.setProperty(\"margin-bottom\", \"\(v / scale)px\", \"important\")"
            }
        }
    }
    
    private class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
        private weak var view: Utils.UI.ExtendedWebView?
        
        init(_ view: Utils.UI.ExtendedWebView) {
            self.view = view
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let view = view, message.webView == view else {
                return
            }
            
            switch message.name {
            case Utils.UI.ExtendedWebView.messageLogging:
                print("[WebView.console.log]:", message.body)
            case Utils.UI.ExtendedWebView.messageReady:
                view.isReady = true
            case Utils.UI.ExtendedWebView.messageBodySize:
                if let sizeMap = message.body as? [String: CGFloat],
                   let w = sizeMap["width"],
                   let h = sizeMap["height"] {
                    view.bodySize = .init(width: w, height: h)
                }
            default:
                break
            }
        }
    }
    
    internal func prepareConfiguration() {
        let ucc = configuration.userContentController
        let smh = ScriptMessageHandler(self)
        ucc.add(smh, name: Utils.UI.ExtendedWebView.messageLogging)
        ucc.add(smh, name: Utils.UI.ExtendedWebView.messageReady)
        ucc.add(smh, name: Utils.UI.ExtendedWebView.messageBodySize)

        // logging
        ucc.addUserScript(.init(source:
            """
                var console = {
                    log: function(msg) {
                        window.webkit.messageHandlers.logging.postMessage(msg)
                    }
                };
            """, injectionTime: .atDocumentStart, forMainFrameOnly: false))
        
        
        // body display
        ucc.addUserScript(.init(source:
            """
                document.body.style.display = "none";
                document.onreadystatechange = function () {
                    if (document.readyState === 'complete') {
                        webkit.messageHandlers.ready.postMessage(\"\");
                    }
                }
                
            """,
        injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        
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
    
    internal func prepareRx() {
        typealias O = Observable<Margin>
                
        let hv = headerContainerView
        let fv = footerContainerView
        
        /*
         Top inset (margin) based on header view height.
        */
        let hh: O = hv.rx.observeWeakly(CGRect.self, #keyPath(UIView.bounds), options: [.new])
            .pausableBuffered($freezeHeaderBounds.value.map { !$0 }, limit: 1)
            .map { .top($0?.height ?? 0) }
        
        /*
         Bottom inset (margin) based on footer view height.
        */
        let hf: O = fv.rx.observeWeakly(CGRect.self, #keyPath(UIView.bounds), options: [.new])
            .map { .bottom($0?.height ?? 0) }
        
        [hh, hf].forEach {
            // combine with zoom scalee
            Observable.combineLatest(zoomScale, $0)
                .pausableBuffered($isReady.value, limit: 1)
                .subscribe(with: self, onNext: {
                    $0.evaluateJavaScript($1.1.script(for: $1.0))
                })
                .disposed(by: disposeBag)
        }
    }
}
