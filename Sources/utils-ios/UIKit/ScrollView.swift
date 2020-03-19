//
//  ScrollView.swift
//  
//
//  Created by Miroslav Yozov on 17.03.20.
//

import UIKit
import WebKit

open class ScrollView: UIScrollView {
    /// UIScrollView.contnetSize observer context
    private var KVOContentSizeContext = 0
    
    private var elements: [Element] = [] {
        didSet {
            defer {
                relayout()
            }
            
            oldValue.forEach {
                $0.view.removeFromSuperview()
                
                if let scrollView = $0.scrollView {
                    scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
                }
            }
            
            elements.forEach {
                addSubview($0.view)
                
                if let scrollView = $0.scrollView {
                    scrollView.isScrollEnabled = false // disable scrolling so it does not interfere with the parent scroll
                    scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: [.old], context: &KVOContentSizeContext)
                }
            }
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
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        updateContentSize()
        adjustContentOnScroll()
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &KVOContentSizeContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        guard let object = object as? UIScrollView, elements.contains(where: { return $0.scrollView == object }) else {
            return
        }
        
        if keyPath == #keyPath(UIScrollView.contentSize) {
            guard let oldSize = change?[.oldKey] as? CGSize, oldSize != object.contentSize else {
                return
            }

            relayout()
        }
    }
}

fileprivate extension ScrollView {
    /// This function is used to calculate the rect of each view into the stack and put it in place.
    /// It's called when a new array of views is set.
    func updateContentSize() {
        // Setup manyally the content size and adjust the items based upon the visibility
        contentSize = .init(width: frame.width, height: elements.reduce(into: 0) {
            var height: CGFloat = 0
            if let scrollView = $1.scrollView {
                // for webview/table/collections/scrollview the occupied space is calculated with the content size of scroll
                // itself and specified inset of it inside the parent view.
                // take care of the insets
                height = scrollView.contentSize.height + scrollView.contentInset.top + scrollView.contentInset.bottom
            } else {
                height = $1.view.systemLayoutSizeFitting(.init(width: frame.width, height: 0),
                                                              withHorizontalFittingPriority: .required,
                                                              verticalFittingPriority: .defaultLow).height
                if height == 0 {
                    print(self, $1.view, "Does not specify a valid height.")
                }
            }
            
            // This is the ideal rect
            // don't worry, its adjusted below
            $1.rect = .init(x: 0.0, y: $0, width: frame.width, height: height)
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
        let width = frame.width
        
        // This is the visible rect of the parent scroll view
        let visibleRect: CGRect = .init(x: 0.0, y:mainOffsetY, width: width, height: frame.height)
        
        // Enumerate each item of the stack
        elements.forEach {
            guard let innerScroll = $0.scrollView else { return }
            
            let itemRect = $0.rect // get the ideal rect (occupied space)
            
            // evaluate the visible region in parent
            let itemVisibleRect = visibleRect.intersection(itemRect)
            guard !itemVisibleRect.height.isZero else {
                // If not visible the frame of the inner's scroll is canceled.
                $0.defaults()
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
                // This is the height of the visible region of the inner table/collection
                let visibleInnerHeight = innerScroll.contentSize.height - innerScrollOffsetY
                
                var innerScrollRect: CGRect = .zero
                innerScrollRect.origin = .init(x: 0, y: itemRect.origin.y + innerScrollOffsetY)
                if visibleInnerHeight < visibleRect.size.height {
                    // partially visible when pinned on top
                    innerScrollRect.size = .init(width: width, height: min(visibleInnerHeight,itemVisibleRect.height))
                } else {
                    // the inner scroll occupy the entire parent scroll's height
                    innerScrollRect.size = itemVisibleRect.size
                }
                
                $0.view.frame = innerScrollRect
                
                // adjust the offset to simulate the scroll
                innerScroll.contentOffset = .init(x: 0, y: innerScrollOffsetY)
            } else {
                // The inner scroll view is partially visible
                // Adjust the frame as it needs (at its max it reaches the height of the parent)
                let offsetOfInnerY = (itemRect.minY) - mainOffsetY
                let visibileHeight = visibleRect.size.height - offsetOfInnerY
                
                $0.view.frame = .init(origin: itemRect.origin, size: .init(width: width, height: min(visibileHeight, itemVisibleRect.height)))
                innerScroll.contentOffset = .zero
            }
        }
    }
}

public extension ScrollView {
    /// Reference to scrolling views.
    var views: [UIView] {
        get {
            return elements.map { return $0.view }
        }
        set {
            elements = newValue.map { .init($0) }
        }
    }
    
    /// Relayout.
    func relayout() {
        setNeedsLayout()
        layoutIfNeeded()
    }
}

fileprivate extension ScrollView {
    class Element {
        let view: UIView
        
        var scrollView: UIScrollView? {
            return view as? UIScrollView ?? (view as? WKWebView)?.scrollView
        }
        
        var rect: CGRect = .zero {
            didSet {
                if rect != oldValue {
                    view.frame = .init(origin: rect.origin, size: .init(width: rect.width, height: scrollView == nil ? rect.height : 0))
                }
            }
        }
        
        init(_ view: UIView) {
            self.view = view
        }
        
        func defaults() {
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
    }
}
