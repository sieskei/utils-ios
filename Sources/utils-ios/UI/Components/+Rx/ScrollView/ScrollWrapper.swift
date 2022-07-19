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
        private var outerDisposeBag: DisposeBag = .init()
        private var innerDisposeBag: DisposeBag = .init()
        
        private weak var outerScrollView: UIScrollView? {
            didSet {
                outerDisposeBag = .init()
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
                    .disposed(by: outerDisposeBag)
            }
        }
        
        private let scrollCompatible: T
        
        private lazy var innerTopConstraint: NSLayoutConstraint = {
            let c: NSLayoutConstraint = scrollCompatible.view.topAnchor.constraint(equalTo: topAnchor, constant: 0)
            c.priority = .init(999)
            c.isActive = true
            return c
        }()
        
        private lazy var innerHeightConstraint: NSLayoutConstraint = {
            let c: NSLayoutConstraint = scrollCompatible.view.heightAnchor.constraint(equalToConstant: 0)
            c.priority = .init(999)
            c.isActive = true
            return c
        }()
        
        public init(_ s: T, dualView: Bool = false) {
            scrollCompatible = s
            
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
            
            let _ = innerTopConstraint
            let _ = innerHeightConstraint
            
            let c: NSLayoutConstraint = heightAnchor.constraint(equalToConstant: s.scrollSize.height)
            c.isActive = true
            
            s.rx.scrollSize
                .map { $0.height }
                .`do`(with: self, afterNext: { this, _ in
                    if let sv = this.outerScrollView {
                        sv.setNeedsLayout()
                    }
                })
                .bind(to: c.rx.constant)
                .disposed(by: innerDisposeBag)
        }
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func didMoveToSuperview() {
            super.didMoveToSuperview()
            outerScrollView = superview?.traverseViewHierarchyForClassType()
        }
    }
}
