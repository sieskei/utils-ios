//
//  UIScrollView+Wrapper.swift
//  
//
//  Created by Miroslav Yozov on 29.12.20.
//

import UIKit
import RxSwift
import RxSwiftExt

extension Utils.UI {
    open class ScrollWrapper<T: UtilsUIScrollCompatible>: Utils.UI.View {
        private var bags: (outer: DisposeBag, inner: DisposeBag) = (.init(), .init())
        
        private weak var outerScrollView: UIScrollView? {
            didSet {
                bags.outer = .init()
                guard let sv = outerScrollView else {
                    return
                }
                
                sv.rx.methodInvoked(#selector(UIScrollView.layoutSubviews))
                    .observe(on: MainScheduler.asyncInstance)
                    .subscribeNext(with: self) { this, _ in
                        let i = this.frame.intersection(.init(origin: sv.contentOffset, size: sv.bounds.size))
                        
                        let h = i.height
                        let m = i.origin.y - this.frame.origin.y
                        
                        this.innerHeightConstraint.constant = h
                        this.innerTopConstraint.constant = m.isInfinite ? 0 : m
                        this.scrollCompatible.scrollView.contentOffset.y = this.innerTopConstraint.constant
                    }
                    .disposed(by: bags.outer)
            }
        }
        
        private let scrollCompatible: T
        
        private lazy var innerTopConstraint: NSLayoutConstraint = (scrollCompatible.view.topAnchor == topAnchor) ~> {
            $0.priority = .init(999)
            $0.isActive = true
        }
        
        private lazy var innerHeightConstraint: NSLayoutConstraint = (scrollCompatible.view.heightAnchor == 0) ~> {
            $0.priority = .init(999)
            $0.isActive = true
        }
        
        public init(_ s: T, dualView: Bool = false) {
            scrollCompatible = s
            
            let v = s.view
            let sv = s.scrollView
            sv.isScrollEnabled = false
            
            super.init(frame: .zero)
            
            if dualView {
                Utils.UI.View() ~> {
                    $0.backgroundColor = .clear
                    $0.clipsToBounds = true
                    
                    layout($0).edges()
                    $0.layout(v)
                }
            } else {
                clipsToBounds = true
                layout(v)
            }
            
            v.layout
                .left()
                .right()
                .top(.zero, >=)
                .bottom(.zero, <=)
            
            let _ = innerTopConstraint
            let _ = innerHeightConstraint
            
            // observe content size
            (heightAnchor == s.scrollSize.height) ~> {
                s.rx.scrollSize
                    .map { $0.height }
                    .`do`(with: self, afterNext: { this, _ in
                        if let sv = this.outerScrollView {
                            sv.setNeedsLayout()
                        }
                    })
                    .bind(to: $0.rx.constant)
                    .disposed(by: bags.inner)
            }
        }
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func didMoveToSuperview() {
            super.didMoveToSuperview()
            outerScrollView = traverseViewHierarchyForClassType()
        }
    }
}
