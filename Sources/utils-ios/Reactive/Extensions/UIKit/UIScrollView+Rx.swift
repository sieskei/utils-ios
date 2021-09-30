//
//  UIScrollView+Rx.swift
//  
//
//  Created by Miroslav Yozov on 24.09.21.
//

import UIKit
import RxSwift

extension Reactive where Base: UIScrollView {
    public var contentSize: Observable<CGSize> {
        observeWeakly(CGSize.self, #keyPath(UIScrollView.contentSize), options: [.initial, .new])
            .unwrap()
    }
    
    public var zoomScale: Observable<CGFloat> {
        didZoom
            .withUnretained(base)
            .map { this, _ in this.zoomScale }
            .startWith(base.zoomScale)
            .map { round($0 * 1000) / 1000.0 }
            .distinctUntilChanged()
    }
}
