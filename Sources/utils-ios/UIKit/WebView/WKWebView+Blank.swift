//
//  WKWebView+Blank.swift
//  
//
//  Created by Miroslav Yozov on 6.09.20.
//

import WebKit

public extension WKWebView {
    static let htmlBlank: String =
    """
    <html>
        <head>
            <meta name="viewport" content="user-scalable=no, width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1">
            <style type="text/css">
                \(WKWebView.cssNormalize)
            </style>
        </head>
        <body>
            <!-- Empty -->
        </body>
    </html>
    """
}
