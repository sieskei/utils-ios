//
//  WebView.swift
//  
//
//  Created by Miroslav Yozov on 9.12.19.
//

import UIKit
import WebKit

public protocol WebViewUIDelegate: WKUIDelegate {
    func webView(_ webView: WebView, didUpdate contentSize: CGSize)
}

open class WebView: WKWebView {
    private var KVOContext = 0
    
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
}

// ---------------------------- //
// MARK: WKScriptMessageHandler //
// ---------------------------- //
fileprivate extension WebView {
    class ContentHeightMessageHandler: NSObject, WKScriptMessageHandler {
        static let name = "contentSize"
        
        struct Size: Decodable {
            let width: CGFloat
            let height: CGFloat
        }
        
        weak var webView: WebView?
        
        init(webView: WebView) {
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
