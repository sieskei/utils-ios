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
    
    /// Must return keyPath to CGSize value
    var scrollSizeKeyPath: String { get }
    
    /// Must return keyPath to UIEdgeInsets value
    var scrollInsetKeyPath: String { get }
}

extension UtilsUIScrollCompatible {
    public var scrollSize: CGSize {
        Utils.castOrFatalError(value(forKeyPath: scrollSizeKeyPath))
    }
    
    public var scrollInset: UIEdgeInsets {
        Utils.castOrFatalError(value(forKeyPath: scrollInsetKeyPath))
    }
    
    public var scrollDimensions: CGSize {
        .init(width: scrollSize.width + scrollInset.horizontal, height: scrollSize.height + scrollInset.vertical)
    }
}


// MARK: - Implementations
extension UIScrollView: UtilsUIScrollCompatible {
    public var scrollView: UIScrollView { self }
    
    public var scrollSizeKeyPath: String {
        "contentSize"
    }
    
    public var scrollInsetKeyPath: String {
        "contentInset"
    }
}

extension Utils.UI.WebView: UtilsUIScrollCompatible {
    public var scrollSizeKeyPath: String {
        "bodySizeValue"
    }
    
    public var scrollInsetKeyPath: String {
        "scrollView.contentInset"
    }
}
