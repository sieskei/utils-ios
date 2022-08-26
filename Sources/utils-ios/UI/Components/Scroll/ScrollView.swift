//
//  ScrollView.swift
//
//
//  Created by Miroslav Yozov on 17.03.20.
//

import UIKit
import WebKit

extension Utils.UI {
    open class ScrollView: UIScrollView {
        private var layouting: Bool = false
        
        private var elements: [Element] = [] {
            didSet {
                oldValue.forEach {
                    $0.view.removeFromSuperview()
                }
                
                updateContentSize()
                
                elements.forEach {
                    addSubview($0.view)
                    
                    $0.onResize { [weak self] _ in
                        guard let this = self, !this.layouting else {
                            return
                        }
                        this.asyncLayout()
                    }
                }
                
                asyncLayout()
            }
        }
        
        public convenience init() {
            self.init(frame: .zero)
            prepare()
        }
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            prepare()
        }
        
        required public init?(coder: NSCoder) {
            super.init(coder: coder)
            prepare()
        }
        
        public func prepare() {
            clipsToBounds = true
            contentScaleFactor = UIScreen.main.scale
            alwaysBounceVertical = true
        }
        
        open override func layoutSubviews() {
            layouting = true
            defer {
                layouting = false
            }
            
            super.layoutSubviews()
            
            updateContentSize()
            adjustContentOnScroll()
        }
    }
}


public extension Utils.UI.ScrollView {
    /// Reference to scrolling views.
    var views: [UIView] {
        get {
            elements.map { $0.view }
        }
        set {
            elements = newValue.map { .init($0)}
        }
    }
    
    /// Relayout.
    func relayout() {
        asyncLayout()
    }
}

fileprivate extension Utils.UI.ScrollView {
    /// This function is used to calculate the rect of each view into the stack and put it in place.
    /// It's called when a new array of views is set.
    func updateContentSize() {
        // Setup manyally the content size and adjust the items based upon the visibility
        contentSize = .init(width: bounds.width, height: elements.reduce(into: 0) {
            let height = $1.height(for: bounds)
            
            // This is the ideal rect
            // don't worry, its adjusted below
            $1.rect = .init(x: 0, y: $0, width: bounds.width, height: height)
            $0 += height // calculate the new offset
        })
    }
    
    /// This function is used to adjust the frame of the object as the parent
    /// scroll view did scroll.
    /// How it works:
    /// - No scrolling views are showed as is. No changes are applied to the frame of the view itself.
    /// - Scrolling views are managed by adjusting the specified
    ///   scrollview's offset and frame in order to take care of the visibility region into the
    ///   parent scroll view.
    func adjustContentOnScroll() {
        let mainOffsetY = contentOffset.y
        
        // This is the scroll view width
        let width = bounds.width
        
        // This is the visible rect of the parent scroll view
        let visibleRect: CGRect = .init(x: 0.0, y:mainOffsetY, width: width, height: bounds.height)
        
        // Enumerate each item of the stack
        elements.forEach {
            guard let innerScroll = $0.scrollView else { return }
            
            let itemRect = $0.rect // get the ideal rect (occupied space)
            
            // evaluate the visible region in parent
            let itemVisibleRect = visibleRect.intersection(itemRect)
            guard !itemVisibleRect.height.isZero else {
                // If not visible the frame of the inner's scroll is canceled.
                $0.offScreen()
                return
            }
            
            // The item is partially visible
            if mainOffsetY > itemRect.minY {
                // If during scrolling the inner webview/table/collection has reached the top
                // of the parent scrollview it will be pinned on top
                
                // This calculate the offset reached while scrolling the inner scroll
                // It's used to adjust the inner table/collection offset in order to
                // simulate continous scrolling
                let innerScrollOffsetY = mainOffsetY - itemRect.minY
                // This is the height of the visible region of the inner scroll
                let visibleInnerHeight = innerScroll.contentSize.height - innerScrollOffsetY
                
                var innerScrollRect: CGRect = .zero
                innerScrollRect.origin = .init(x: 0, y: itemRect.origin.y + innerScrollOffsetY)
                if visibleInnerHeight < visibleRect.size.height {
                    // partially visible when pinned on top
                    innerScrollRect.size = .init(width: width, height: min(visibleInnerHeight, itemVisibleRect.height))
                } else {
                    // the inner scroll occupy the entire parent scroll's height
                    innerScrollRect.size = itemVisibleRect.size
                }
                
                $0.view.frame = innerScrollRect
                
                // adjust the offset to simulate the scroll
                innerScroll.contentOffset = .init(x: 0, y: min(innerScrollOffsetY, innerScroll.maxContentOffset.y))
            } else {
                // The inner scroll view is partially visible
                // Adjust the frame as it needs (at its max it reaches the height of the parent)
                let offsetOfInnerY = (itemRect.minY) - mainOffsetY
                let visibileHeight = visibleRect.size.height - offsetOfInnerY
                
                $0.view.frame = .init(origin: itemRect.origin, size: .init(width: width, height: min(visibileHeight, itemVisibleRect.height)))
                innerScroll.contentOffset = innerScroll.minContentOffset
            }
        }
    }
}

fileprivate extension Utils.UI.ScrollView {
    class Element {
        let view: UIView
        var observation: NSKeyValueObservation? = nil
        
        var scrollView: UIScrollView? {
            return view as? UIScrollView ?? (view as? WKWebView)?.scrollView
        }
        
        var rect: CGRect = .zero {
            didSet {
                guard rect != oldValue else {
                    return
                }
                view.frame = .init(origin: rect.origin, size: .init(width: rect.width, height: scrollView == nil ? rect.height : view.frame.height))
            }
        }
        
        init(_ view: UIView) {
            self.view = view
            self.scrollView?.isScrollEnabled = false // disable scrolling so it does not interfere with the parent scroll
        }
        
        func onResize(_ callback: @escaping (Element) -> Void) {
            let ops: NSKeyValueObservingOptions = [.old, .new, .initial]
            let handler:  (UIView, NSKeyValueObservedChange<CGSize>) -> Void = { [weak self] in
                guard let this = self, $1.oldValue != $1.newValue else {
                    return
                }
                callback(this)
            }
            
            if let sv = view as? UIScrollView {
                observation = sv.observe(\UIScrollView.contentSize, options: ops, changeHandler: handler)
            } else if let wv = view as? Utils.UI.WebView {
                observation = wv.observe(\Utils.UI.WebView.bodySizeValue, options: ops, changeHandler: handler)
            }
        }
        
        func height(for bounds: CGRect) -> CGFloat {
            if let sv = view as? UIScrollView {
                return sv.contentInset.top + sv.contentSize.height + sv.contentInset.bottom
            } else if let wv = view as? Utils.UI.WebView {
                return wv.scrollView.contentInset.top + wv.bodySize.value.height + wv.scrollView.contentInset.bottom
            } else {
                return view.systemLayoutSizeFitting(.init(width: bounds.width, height: 0),
                                                    withHorizontalFittingPriority: .required,
                                                    verticalFittingPriority: .defaultLow).height
            }
        }
        
        func offScreen() {
            var h = rect.height
            if let sv = scrollView {
                sv.contentOffset = .zero
                h = 0
            }
            let f: CGRect = .init(origin: rect.origin, size: .init(width: rect.width, height: h))
            if view.frame != f {
                view.frame = f
            }
        }
        
        deinit {
            observation = nil
            print(self, "deinit ...")
        }
    }
}
