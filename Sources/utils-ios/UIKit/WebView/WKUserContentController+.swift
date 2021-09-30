//
//  WKUserContentController+.swift
//  
//
//  Created by Miroslav Yozov on 23.09.21.
//

import WebKit

public extension WKUserContentController {
    typealias ReceiverType = (_ message: WKScriptMessage) -> Void
    
    private class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
        private let receive: ReceiverType
        
        init(receive r: @escaping ReceiverType) {
            receive = r
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            receive(message)
        }
    }
    
    func addScriptMessageHandler(name: String, receive: @escaping ReceiverType) {
        add(ScriptMessageHandler(receive: receive), name: name)
    }
}
