//
//  NIWebView.swift
//  
//
//  Created by Miroslav Yozov on 25.08.20.
//

import UIKit
import WebKit

open class NIWebView: WKWebView {
    public enum BodySize {
        case ready(CGSize)
        case senor(CGSize)
        
        public var value: CGSize {
            switch self {
            case .ready(let s), .senor(let s):
                return s
            }
        }
    }
    
    @RxProperty
    public private (set) var isReady: Bool = false
    
    @RxProperty
    public private (set) var bodySize: BodySize = .ready(.zero)
    
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
        prepare()
    }
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        resizeSensor = true
        super.init(frame: frame, configuration: configuration)
        prepare()
    }
    
    public required init?(coder: NSCoder) {
        resizeSensor = true
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
        bodySize = .ready(.zero)
    }
    
    deinit {
        print(self, "deinit ...")
    }
}

extension NIWebView {
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
        
        
        // MARK: Document ready state
        ucc.addScriptMessageHandler(name: "ready") { [weak self] message in
            guard let this = self else {
                return
            }
            
            this.bodySize = .ready(message.size ?? .zero)
            this.isReady = true
        }
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
        
        
        // MARK: Body resize sensor
        if resizeSensor {
            ucc.addScriptMessageHandler(name: "bodysize") { [weak self] message in
                if let this = self, let size = message.size {
                    this.bodySize = .senor(size)
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
           let w = sizeMap["width"],
           let h = sizeMap["height"] {
            return .init(width: w, height: h)
        } else {
            return nil
        }
    }
}
