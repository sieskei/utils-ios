//
//  UIScrollView+.swift
//  
//
//  Created by Miroslav Yozov on 24.12.19.
//

import UIKit

public extension UIScrollView {
    var maxContentOffset: CGPoint {
        return .init(x: contentSize.width - bounds.width + contentInset.right,
                     y: contentSize.height - bounds.height + contentInset.bottom)
    }
    
    var minContentOffset: CGPoint {
        return .init(x: -contentInset.left, y: -contentInset.top)
    }
    
    var contentFillsVerticalScrollEdges: Bool {
        return contentSize.height + contentInset.top + contentInset.bottom >= bounds.height
    }
    
    var contentFillsHorizontalScrollEdges: Bool {
        return contentSize.width + contentInset.left + contentInset.right >= bounds.width
    }
}

public extension UIScrollView {
    var bounceTopOffsetRaw: CGFloat {
        return contentOffset.y + contentInset.top
    }
    
    var bounceLeftOffsetRaw: CGFloat {
        return contentOffset.x + contentInset.left
    }
    
    var bounceBottomOffsetRaw: CGFloat {
        return contentOffset.y - maxContentOffset.y
    }
    
    var bounceRightOffsetRaw: CGFloat {
        return contentOffset.x - maxContentOffset.x
    }
    
    var bounceTopOffset: CGFloat {
        return -min(0, bounceTopOffsetRaw)
    }
    
    var bounceLeftOffset: CGFloat {
        return -min(0, bounceLeftOffsetRaw)
    }
    
    var bounceBottomOffset: CGFloat {
        return max(0, bounceBottomOffsetRaw)
    }
    
    var bounceRightOffset: CGFloat {
        return max(0, bounceRightOffsetRaw)
    }
}

public extension UIScrollView {
    var isBouncing: Bool {
        return isBouncingTop || isBouncingLeft || isBouncingBottom || isBouncingRight
    }
        
    var isBouncingTop: Bool {
        return bounceTopOffset > 0
    }

    var isBouncingLeft: Bool {
        return bounceLeftOffset > 0
    }
    
    var isBouncingBottom: Bool {
        return contentFillsVerticalScrollEdges && bounceBottomOffset > 0
    }
    
    var isBouncingRight: Bool {
        return contentFillsHorizontalScrollEdges && bounceRightOffset > 0
    }
}
