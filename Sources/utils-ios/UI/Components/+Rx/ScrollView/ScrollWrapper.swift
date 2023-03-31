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
                    .withUnretained(sv)
                    .map { s, _ in (s.contentOffset, s.bounds.size)}
                    .withUnretained(self)
                    .map { $0.frame.intersection(.init(origin: $1.0, size: $1.1)) }
                    .distinctUntilChanged()
                    .subscribeNext(with: self) { this, i in
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
        
        private lazy var innerTopConstraint: NSLayoutConstraint = scrollCompatible.topAnchor == topAnchor ~ .init(999)
        private lazy var innerHeightConstraint: NSLayoutConstraint = scrollCompatible.heightAnchor == 0 ~ .init(999)
        
        public init(_ s: T, dualView: Bool = false) {
            scrollCompatible = s
            
            let sv = s.scrollView
            sv.bounces = false
            sv.isScrollEnabled = false
            sv.showsVerticalScrollIndicator = false
            sv.showsHorizontalScrollIndicator = false
            
            super.init(frame: .zero)
            
            if dualView {
                Utils.UI.View() ~> {
                    $0.backgroundColor = .clear
                    $0.clipsToBounds = true
                    
                    layout($0).edges()
                    $0.layout(s)
                }
            } else {
                clipsToBounds = true
                layout(s)
            }
            
            s.layout
                .left()
                .right()
                .top(.zero, >=)
                .bottom(.zero, <=)
            
            let _ = innerTopConstraint
            let _ = innerHeightConstraint
            
            // observe content size
            (heightAnchor == s.scrollSize.height) ~> {
                s.rx.scrollDimensions
                    .map { $0.height }
                    .`do`(with: self, afterNext: { this, _ in
                        this.outerScrollView ~> { $0.setNeedsLayout() }
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
        
        deinit {
            Utils.Log.debug("deinit ...", self)
        }
    }
}
