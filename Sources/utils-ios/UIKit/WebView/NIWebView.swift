//
//  NIWebView.swift
//  
//
//  Created by Miroslav Yozov on 25.08.20.
//

import UIKit
import WebKit

open class NIWebView: WKWebView {
    @objc
    public fileprivate (set) dynamic var bodySize: CGSize = .zero
    
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
    
    deinit {
        print(self, "deinit ...")
    }
}

fileprivate extension NIWebView {
    private static var messageLogging = "logging"
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
            case NIWebView.messageBodySize:
                guard let sizeMap = message.body as? [String: CGFloat],
                    let w = sizeMap["width"],
                    let h = sizeMap["height"] else {
                        return
                }
                view.bodySize = .init(width: w, height: h)
            default:
                break
            }
        }
    }
    
    func prepareConfiguration() {
        let ucc = configuration.userContentController
        let smh = ScriptMessageHandler(self)
        ucc.add(smh, name: NIWebView.messageLogging)
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
        
        // resize sensor
        ucc.addUserScript(.init(source: ResizeSensor.source, injectionTime: .atDocumentStart, forMainFrameOnly: true))
        
        // body resize notifier
        ucc.addUserScript(.init(source:
            """
                notify = function() {
                    var rect = document.body.getBoundingClientRect();
                    window.webkit.messageHandlers.bodysize.postMessage({ width: rect.width, height: rect.height });
                }

                new ResizeSensor(document.body, function() {
                    notify();
                });

                notify();
            """, injectionTime: .atDocumentEnd, forMainFrameOnly: true))
    }
}
