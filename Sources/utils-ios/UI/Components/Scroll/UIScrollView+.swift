//
//  UIScrollView+.swift
//  
//
//  Created by Miroslav Yozov on 24.12.19.
//

import UIKit

public extension UIScrollView {
    var visibleRect: CGRect {
        .init(origin: contentOffset, size: bounds.size)
    }
    
    var minContentOffset: CGPoint {
        .init(x: -contentInset.left, y: -contentInset.top)
    }
    
    var maxContentOffset: CGPoint {
        var point = minContentOffset
        point.x += max(0, (contentInset.left + contentSize.width + contentInset.right) - bounds.width)
        point.y += max(0, (contentInset.top + contentSize.height + contentInset.bottom) - bounds.height)
        return point
    }
    
    var contentFillsVerticalScrollEdges: Bool {
        contentSize.height + contentInset.top + contentInset.bottom >= bounds.height
    }
    
    var contentFillsHorizontalScrollEdges: Bool {
        contentSize.width + contentInset.left + contentInset.right >= bounds.width
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


public extension UIScrollView {
    func transition(toContentOffset point: CGPoint, duration: TimeInterval = 0.25, completion: ((Bool) -> Void)? = nil) {
        contentOffset = point
        
        guard window != nil else {
            return // not added to view hierarchy yet
        }
        
        UIView.transition(with: self, duration: duration, options: [.transitionCrossDissolve, .beginFromCurrentState], animations: { [weak self] in
            if let this = self {
                this.layoutIfNeeded()
            }
        }, completion: completion)
    }
}
