//
//  SimpleWebView.swift
//  
//
//  Created by Miroslav Yozov on 19.11.22.
//

import UIKit
import WebKit
import RxSwift

extension Utils.UI {
    open class SimpleWebView: WKWebView {
        open var viewport: String {
            .init()
        }
        
        open var style: String {
            .init()
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
            prepareConfiguration()
        }
    }
}

extension Utils.UI.SimpleWebView {
    @objc
    open dynamic func prepareConfiguration() {
        let ucc = configuration.userContentController
        
        // MARK: Logging
        ucc.addScriptMessageHandler(name: "logging") {
            Utils.Log.debug("[NIWebView.console.log]:", $0.body)
        }
        ucc.addUserScript(.init(source:
            """
                var console = {
                    log: function(msg) {
                            window.webkit.messageHandlers.logging.postMessage(msg)
                         }
                };
            """, injectionTime: .atDocumentStart, forMainFrameOnly: false))
        
        
        // MARK: Viewport meta tag (if provided)
        if !viewport.isEmpty {
            let script =
            """
                var meta = document.getElementsByTagName('meta')['viewport']
                if (!meta) {
                    meta = document.createElement('meta');
                    meta.name = 'viewport'
                    document.head.appendChild(meta);
                }
                meta.content = '\(viewport)';
            """

            configuration
                .userContentController
                .addUserScript(WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        }
        
        
        // MARK: CSS Style tag (if provided)
        if !style.isEmpty {
            let script =
            """
                var style = document.createElement('style')
                style.innerText = `\(style)`
                document.head.appendChild(style)
            """

            configuration
                .userContentController
                .addUserScript(WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        }
    }
}

