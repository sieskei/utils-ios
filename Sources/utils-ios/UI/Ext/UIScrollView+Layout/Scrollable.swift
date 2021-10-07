//
//  Scrollable.swift
//  
//
//  Created by Miroslav Yozov on 2.03.21.
//

import UIKit

public protocol Scrollable: NSObject {
    var view: UIView { get }
    var scrollView: UIScrollView { get }
    
    var scrollSizeKeyPath: String { get }
}

extension UIScrollView: Scrollable {
    public var view: UIView { self }
    public var scrollView: UIScrollView { self }
    
    public var scrollSizeKeyPath: String {
        return "contentSize"
    }
}

extension NIWebView: Scrollable {
    public var view: UIView { self }
    
    public var scrollSizeKeyPath: String {
        return "bodySize"
    }
}
