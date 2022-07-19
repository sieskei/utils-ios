//
//  ScrollCompatible.swift
//  
//
//  Created by Miroslav Yozov on 19.07.22.
//

import UIKit
import RxSwift
import RxSwiftExt

public protocol UtilsUIScrollCompatible: NSObject {
    var view: UIView { get }
    var scrollView: UIScrollView { get }
    var scrollSizeKeyPath: String { get } // must return keyPath to CGSize value
}

extension UtilsUIScrollCompatible {
    public var scrollSize: CGSize {
        Utils.castOrFatalError(value(forKeyPath: scrollSizeKeyPath))
    }
}


// MARK: - Implementations
extension UIScrollView: UtilsUIScrollCompatible {
    public var view: UIView { self }
    public var scrollView: UIScrollView { self }
    
    public var scrollSizeKeyPath: String {
        return "contentSize"
    }
}

extension Utils.UI.WebView: UtilsUIScrollCompatible {
    public var view: UIView { self }
    
    public var scrollSizeKeyPath: String {
        return "bodySize"
    }
}




