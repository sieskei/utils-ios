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

open class WebViewV2: WKWebView {
    private let disposeBag = DisposeBag()
    
    @RxProperty
    private var isReady: Bool = false
    
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
        scrollView.rx.contentOffset.map(unowned: self) { -($0.scrollView.contentInset.top + $1.y) }
    }
    
    open var footerTopConstraintConstant: Observable<CGFloat> {
        /*
         Scroll view content size.
         */
        let cs = scrollView.rx.observeWeakly(CGSize.self, #keyPath(UIScrollView.contentSize))
            .map { $0?.height ?? 0 }
            .do(onNext: {
                print("CCC", $0, self.scrollView.bounds.height)
            })
        
        return cs
        
//        return Observable.combineLatest(cs).map {
//            return max(0, $0)
//        }
    }
    
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
        
        prepareConfiguration()
        
        prepareHeaderContainerView()
        prepareFooterContainerView()
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return headerContainerView.hitTest(convert(point, to: headerContainerView), with: event) ??
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
        print(self, "called ...")
    }
}


// -------------------------------------------
// MARK: Prepeare header and footer containrs.
// -------------------------------------------
fileprivate extension WebViewV2 {
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
        scrollView.addSubview(view)
        
        // dynamic top constraint
        let topConstraint = view.topAnchor.constraint(equalTo: topAnchor)
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
extension WebViewV2 {
    private class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
        private weak var view: WebViewV2?
        
        init(_ view: WebViewV2) {
            self.view = view
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let view = view, message.webView == view else {
                return
            }
            
            switch message.name {
            case WebViewV2.messageLogging:
                print("[WebView.console.log]:", message.body)
            case WebViewV2.messageReady:
                view.ready()
            default:
                break
            }
        }
    }
    
    private enum Margin: Equatable {
        case top(CGFloat)
        case bottom(CGFloat)
        
        var script: String {
            switch self {
            case .top(let v):
                return "document.body.style.marginTop = \"\(v)px\";"
            case .bottom(let v):
                return "document.body.style.marginBottom = \"\(v)px\";"
            }
        }
    }
    
    private static var messageLogging = "logging"
    private static var messageReady = "ready"
    
    internal func prepareConfiguration() {
        let ucc = configuration.userContentController
        ucc.add(ScriptMessageHandler(self), name: WebViewV2.messageLogging)
        ucc.add(ScriptMessageHandler(self), name: WebViewV2.messageReady)

        ucc.addUserScript(.init(source:
            """
                var console = {
                    log: function(msg) {
                            window.webkit.messageHandlers.logging.postMessage(msg)
                         }
                };
            """, injectionTime: .atDocumentStart, forMainFrameOnly: false))
        
        
        ucc.addUserScript(.init(source:
            """
                document.body.style.display = "none";
                webkit.messageHandlers.ready.postMessage(\"\");
            """,
        injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        
        
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
        
        Observable.merge(hh, hf)
            .pausableBuffered($isReady.value, limit: 1)
            .subscribe(with: self, onNext: {
                switch $1 {
                case .top(let v):
                    $0.scrollView.contentInset.top = v
                case .bottom(let v):
                    $0.scrollView.contentInset.bottom = v
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func ready() {
        defer {
            isReady = true
        }
        
        /*
         Set body margins and display.
         */
        evaluateJavaScript(
            """
                document.body.style.display = "initial";
            """
        )
    }
}
