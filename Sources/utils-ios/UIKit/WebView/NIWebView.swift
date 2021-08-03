//
//  NIWebView.swift
//  
//
//  Created by Miroslav Yozov on 25.08.20.
//

import UIKit
import WebKit

open class NIWebView: WKWebView {
    
    @RxProperty
    @objc
    public dynamic private (set)  var bodySize: CGSize = .zero
    
    @RxProperty
    public private (set) var isReady: Bool = false
    
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
        prepareConfiguration()
    }
    
    // ---------------
    // MARK: Load API.
    // ---------------
    
    @discardableResult
    open override func load(_ request: URLRequest) -> WKNavigation? {
        reset()
        return super.load(request)
    }
    
    @discardableResult
    open override func loadFileURL(_ URL: URL, allowingReadAccessTo readAccessURL: URL) -> WKNavigation? {
        reset()
        return super.loadFileURL(URL, allowingReadAccessTo: readAccessURL)
    }
    
    @discardableResult
    open override func load(_ data: Data, mimeType MIMEType: String, characterEncodingName: String, baseURL: URL) -> WKNavigation? {
        reset()
        return super.load(data, mimeType: MIMEType, characterEncodingName: characterEncodingName, baseURL: baseURL)
    }
    
    @discardableResult
    open override func loadHTMLString(_ string: String, baseURL: URL?) -> WKNavigation? {
        reset()
        return super.loadHTMLString(string, baseURL: baseURL)
    }
    
    open func reset() {
        isReady = false
        bodySize = .zero
    }
    
    deinit {
        print(self, "deinit ...")
    }
}

extension NIWebView {
    private static var messageLogging = "logging"
    private static var messageReady = "ready"
    private static var messageBodySize = "bodysize"
    
    private class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
        private weak var view: NIWebView?
        
        init(_ view: NIWebView) {
            self.view = view
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let view = view, message.webView == view else {
                return
            }
            
            switch message.name {
            case NIWebView.messageLogging:
                print("[NIWebView.console.log]:", message.body)
            case NIWebView.messageReady:
                if let sizeMap = message.body as? [String: CGFloat], let w = sizeMap["width"], let h = sizeMap["height"] {
                    view.bodySize = .init(width: w, height: h)
                }
                view.isReady = true
            case NIWebView.messageBodySize:
                if let sizeMap = message.body as? [String: CGFloat], let w = sizeMap["width"], let h = sizeMap["height"] {
                    view.bodySize = .init(width: w, height: h)
                }
            default:
                break
            }
        }
    }
    
    @objc
    open dynamic func prepareConfiguration() {
        let ucc = configuration.userContentController
        let smh = ScriptMessageHandler(self)
        ucc.add(smh, name: NIWebView.messageLogging)
        ucc.add(smh, name: NIWebView.messageReady)
        ucc.add(smh, name: NIWebView.messageBodySize)

        // logging
        ucc.addUserScript(.init(source:
            """
                var console = {
                    log: function(msg) {
                            window.webkit.messageHandlers.logging.postMessage(msg)
                         }
                };
            """, injectionTime: .atDocumentStart, forMainFrameOnly: false))
        
        // ready state
        ucc.addUserScript(.init(source:
            """
                document.onreadystatechange = function () {
                    if (document.readyState === 'complete') {
                        var rect = document.body.getBoundingClientRect();
                        webkit.messageHandlers.ready.postMessage({ width: Math.round(rect.width), height: Math.round(rect.height) });
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
}
