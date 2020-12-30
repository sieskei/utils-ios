//
//  UIScrollView+Wrapper.swift
//  
//
//  Created by Miroslav Yozov on 29.12.20.
//

import UIKit
import Material

public protocol ScrollingView {
    var view: UIView { get }
    var scrollView: UIScrollView { get }
    var scrollSize: CGSize { get }
    
    func observeScrollSize(_ callback: @escaping (CGSize) -> Void) -> NSKeyValueObservation
}

extension UIScrollView: ScrollingView {
    public var view: UIView { self }
    public var scrollView: UIScrollView { self }
    public var scrollSize: CGSize { contentSize }
    
    public func observeScrollSize(_ callback: @escaping (CGSize) -> Void) -> NSKeyValueObservation {
        observe(\Self.contentSize, options: [.old, .new, .initial]) { [weak self] in
            if let s = self, $1.oldValue != $1.newValue {
                callback(s.contentSize)
            }
        }
    }
}

extension NIWebView: ScrollingView {
    public var view: UIView { self }
    public var scrollSize: CGSize { bodySize }
    
    public func observeScrollSize(_ callback: @escaping (CGSize) -> Void) -> NSKeyValueObservation {
        observe(\Self.bodySize, options: [.old, .new, .initial]) { [weak self] in
            if let s = self, $1.oldValue != $1.newValue {
                callback(s.bodySize)
            }
        }
    }
}

extension UIScrollView {
    open class Wrapper: View {
        private var outerScrollObsvervation: NSKeyValueObservation? = nil
        private var innerScrollObsvervation: NSKeyValueObservation? = nil
        
        private weak var outerScrollView: UIScrollView? {
            didSet {
                outerScrollObsvervation = nil
                
                if let sv = outerScrollView {
                    outerScrollObsvervation = sv.observe(\UIScrollView.contentOffset, options: [.old, .new, .initial]) { [weak self] in
                        if let s = self, $1.oldValue != $1.newValue {
                            s.adjustOffset()
                        }
                    }
                }
            }
        }
        
        private let scrollable: ScrollingView

        private lazy var heightConstraint: NSLayoutConstraint = {
            let c: NSLayoutConstraint = heightAnchor.constraint(equalToConstant: scrollable.scrollSize.height)
            c.isActive = true
            return c
        }()
        
        private lazy var innerTopConstraint: NSLayoutConstraint = {
            let c: NSLayoutConstraint = scrollable.view.topAnchor.constraint(equalTo: topAnchor, constant: 0)
            c.priority = .init(999)
            c.isActive = true
            return c
        }()
        
        private lazy var innerHeightConstraint: NSLayoutConstraint = {
            let c: NSLayoutConstraint = scrollable.view.heightAnchor.constraint(equalToConstant: 0)
            c.priority = .init(999)
            c.isActive = true
            return c
        }()
        
        public init(_ s: ScrollingView, dualView: Bool = false) {
            scrollable = s
            
            let v = s.view
            let sv = s.scrollView
            sv.isScrollEnabled = false
            
            super.init(frame: .zero)
            
            v.translatesAutoresizingMaskIntoConstraints = false
            
            if dualView {
                let view = View()
                view.backgroundColor = .clear
                view.clipsToBounds = true
                view.translatesAutoresizingMaskIntoConstraints = false
                addSubview(view)
                NSLayoutConstraint.activate([
                    view.topAnchor.constraint(equalTo: topAnchor),
                    view.bottomAnchor.constraint(equalTo: bottomAnchor),
                    view.leftAnchor.constraint(equalTo: leftAnchor),
                    view.rightAnchor.constraint(equalTo: rightAnchor)
                ])
                view.addSubview(v)
            } else {
                clipsToBounds = true
                addSubview(v)
            }
            
            NSLayoutConstraint.activate([
                v.leftAnchor.constraint(equalTo: leftAnchor),
                v.rightAnchor.constraint(equalTo: rightAnchor),
                
                // betweeen top and bottom
                v.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
                v.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
            ])
            
            let _ = heightConstraint
            let _ = innerTopConstraint
            let _ = innerHeightConstraint
            
            innerScrollObsvervation = s.observeScrollSize { [weak self] in
                if let s = self {
                    s.heightConstraint.constant = $0.height
                    
                    s.setNeedsLayout()
                    s.layoutIfNeeded()
                    
                    s.adjustOffset()
                }
            }
        }
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func didMoveToSuperview() {
            super.didMoveToSuperview()
            outerScrollView = superview?.traverseViewHierarchyForClassType()
        }
        
        private func adjustOffset() {
            guard let sv = outerScrollView else {
                return
            }
            
            let i = frame.intersection(.init(origin: sv.contentOffset, size: sv.bounds.size))

            let h = i.height
            let m = i.origin.y - frame.origin.y

            innerHeightConstraint.constant = h
            innerTopConstraint.constant = m.isInfinite ? 0 : m
            scrollable.scrollView.contentOffset.y = innerTopConstraint.constant
        }
        
        deinit {
            outerScrollObsvervation = nil
            innerScrollObsvervation = nil
        }
    }
}
