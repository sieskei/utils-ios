//
//  UIScrollView+Wrapper.swift
//  
//
//  Created by Miroslav Yozov on 29.12.20.
//

import UIKit

public protocol ScrollableView {
    var view: UIView { get }
    var scrollView: UIScrollView { get }
    
    func observeContentSize(_ callback: @escaping (CGSize) -> Void) -> NSKeyValueObservation
}

extension ScrollableView where Self: UIScrollView {
    public var view: UIView { self }
    public var scrollView: UIScrollView { self }
    
    public func observeContentSize(_ callback: @escaping (CGSize) -> Void) -> NSKeyValueObservation {
        observe(\Self.contentSize, options: [.old, .new, .initial]) { [weak self] in
            if let s = self, $1.oldValue != $1.newValue {
                callback(s.contentSize)
            }
        }
    }
}

extension UIScrollView: ScrollableView { }

extension ScrollableView where Self: NIWebView {
    public var view: UIView { self }
    public var scrollView: UIScrollView { scrollView }
    
    public func observeContentSize(_ callback: @escaping (CGSize) -> Void) -> NSKeyValueObservation {
        observe(\Self.bodySize, options: [.old, .new, .initial]) { [weak self] in
            if let s = self, $1.oldValue != $1.newValue {
                callback(s.bodySize)
            }
        }
    }
}

extension NIWebView: ScrollableView { }

extension UIScrollView {
    public class Wrapper: UIView {
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
        
        
        private let scrollable: ScrollableView

        private lazy var heightConstraint: NSLayoutConstraint = {
            let c: NSLayoutConstraint = heightAnchor.constraint(equalToConstant: 0)
            c.isActive = true
            return c
        }()
        
        private lazy var innerTopConstraint: NSLayoutConstraint = {
            let c: NSLayoutConstraint = scrollable.view.topAnchor.constraint(equalTo: topAnchor, constant: 0)
            c.isActive = true
            return c
        }()
        
        private lazy var innerHeightConstraint: NSLayoutConstraint = {
            let c: NSLayoutConstraint = scrollable.view.heightAnchor.constraint(equalToConstant: 0)
            c.isActive = true
            return c
        }()
        
        public init(_ s: ScrollableView) {
            scrollable = s
            
            let v = s.view
            let sv = s.scrollView
            sv.isScrollEnabled = false
            
            super.init(frame: .zero)
            
            clipsToBounds = true
            
            v.translatesAutoresizingMaskIntoConstraints = false
            addSubview(v)
            NSLayoutConstraint.activate([
                v.leftAnchor.constraint(equalTo: leftAnchor),
                v.rightAnchor.constraint(equalTo: rightAnchor)
            ])
            
            heightConstraint.constant = sv.contentSize.height
            
            innerTopConstraint.constant = 0
            innerHeightConstraint.constant = 0
            
            innerScrollObsvervation = s.observeContentSize { [weak self] in
                if let s = self {
                    s.heightConstraint.constant = $0.height
                    DispatchQueue.main.async { // must be in next loop because frame is not updated yet
                        s.adjustOffset()
                    }
                }
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
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
