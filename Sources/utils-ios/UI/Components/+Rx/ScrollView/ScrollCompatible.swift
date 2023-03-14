//
//  ScrollCompatible.swift
//  
//
//  Created by Miroslav Yozov on 19.07.22.
//

import UIKit
import RxSwift
import RxSwiftExt

public protocol UtilsUIScrollCompatible: NSObject where Self: UIView {
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
    public var scrollView: UIScrollView { self }
    
    public var scrollSizeKeyPath: String {
        return "contentSize"
    }
}

extension Utils.UI.WebView: UtilsUIScrollCompatible {
    public var scrollSizeKeyPath: String {
        return "bodySizeValue"
    }
}
