//
//  WebView.swift
//  
//
//  Created by Miroslav Yozov on 9.12.19.
//

import UIKit
import WebKit

import RxSwift
import RxCocoa

import Material

public protocol WebViewUIDelegate: WKUIDelegate {
    func webView(_ webView: WebViewTMP, didUpdate contentSize: CGSize)
}

open class WebViewTMP: WKWebView {
    private let disposeBag = DisposeBag()
    private var headerViewBoundsDisposable: Disposable? {
        didSet {
            oldValue?.dispose()
            headerViewBoundsDisposable?.disposed(by: disposeBag)
        }
    }
    
    public var headerView: UIView? {
        didSet {
            guard headerView != oldValue else { return }
        
            if let view = oldValue {
                headerViewBoundsDisposable = nil
                scrollView.contentInset.top -= view.bounds.height
            }
            
            if let view = headerView {
                defer {
                    layoutHeader()
                }
                
                headerViewBoundsDisposable = view.rx.observeWeakly(CGRect.self, #keyPath(UIView.bounds))
                    .map { $0?.height ?? 0 }
                    .distinctUntilChanged()
                    .subscribeNextWeakly(weak: scrollView) { scrollView, height in
                        guard scrollView.contentOffset.y + scrollView.contentInset.top >= 0 else {
                             return
                        }

                        let diff = height - scrollView.contentInset.top
                        scrollView.contentInset.top += diff
                    }
            }
        }
    }
    
    public private (set) lazy var scrollPositionMarkers: (top: UIView, bottom: UIView) = {
        let source = scrollView.rx.contentOffset.map { $0.y }.distinctUntilChanged()
        
        // top
        let topView = UIView()
        topView.backgroundColor = .clear
        source.subscribeNextWeakly(weak: topView) {
            if $0.superview != nil {
                $0.layout.top(-$1)
            }
        }.disposed(by: disposeBag)
        
        // bottom
        let bottomView = UIView()
        bottomView.backgroundColor = .clear
        source.subscribeNextWeakly(weaks: bottomView, scrollView) {
            if $0.superview != nil {
                $0.layout.top($1.contentSize.height - $2)
            }
        }.disposed(by: disposeBag)
        
        return (topView, bottomView)
    }()
    
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
        scrollView.backgroundColor = .clear
        
        let handler = ContentHeightMessageHandler(webView: self)
        configuration.userContentController.add(handler, name: ContentHeightMessageHandler.name)
        
        // Load its contents to a String variable.
        let resizeSensorScript = WKUserScript(source: ResizeSensor.source, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(resizeSensorScript)
        
        let heightListenerSource =
        """
            notify = function() {
                var rect = document.body.getBoundingClientRect();
                window.webkit.messageHandlers.contentSize.postMessage({ width: rect.width, height: rect.height });
            }

            new ResizeSensor(document.body, function() {
                notify();
            });

            notify();
        """
        
        let heightListenerScript = WKUserScript(source: heightListenerSource, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(heightListenerScript)
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        layoutHeader()
    }
    
    private func prepareForLayout(_ view: UIView, _ layouter: (Layout) -> Void) {
        guard let superview = superview else  {
            return
        }
        
        if view.superview != superview {
            view.removeFromSuperview()
            
            view.translatesAutoresizingMaskIntoConstraints = false
            superview.insertSubview(view, belowSubview: self)
        }
        
        layouter(view.layout)
    }
    
    private func layoutHeader() {
        guard let view = headerView else {
            return
        }
        
        layoutMarkers()
        
        prepareForLayout(view) {
            $0.left(self)
                .right(self)
                .top(self, 0, <=)
                .bottom(scrollPositionMarkers.top.anchor.top)
        }
    }
    
    private func layoutMarkers() {
        prepareForLayout(scrollPositionMarkers.top) {
            $0.left(self)
                .right(self)
                .top(-scrollView.contentOffset.y)
                .height(0)
        }
        
        prepareForLayout(scrollPositionMarkers.bottom) {
            $0.left(self)
                .right(self)
                .top(-scrollView.contentSize.height)
                .height(0)
        }
    }
}

// ---------------------------- //
// MARK: WKScriptMessageHandler //
// ---------------------------- //
fileprivate extension WebViewTMP {
    class ContentHeightMessageHandler: NSObject, WKScriptMessageHandler {
        static let name = "contentSize"
        
        struct Size: Decodable {
            let width: CGFloat
            let height: CGFloat
        }
        
        weak var webView: WebViewTMP?
        
        init(webView: WebViewTMP) {
            self.webView = webView
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == ContentHeightMessageHandler.name, let webView = webView, let delegate = webView.uiDelegate as? WebViewUIDelegate,
                let sizeMap = message.body as? [String: CGFloat], let width = sizeMap["width"], let height = sizeMap["height"] else {
                    return
            }
            
            delegate.webView(webView, didUpdate: CGSize(width: width, height: height))
        }
    }
}
