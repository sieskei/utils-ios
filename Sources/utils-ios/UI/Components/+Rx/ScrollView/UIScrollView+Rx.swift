//
//  UIScrollView+Rx.swift
//  
//
//  Created by Miroslav Yozov on 24.09.21.
//

import UIKit
import RxSwift

extension UIScrollView {
    public enum VerticalDirection: Int {
        case up
        case down
    }
}

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

extension Reactive where Base: UIScrollView {
    public var didScrollVertically: Observable<UIScrollView.VerticalDirection> {
        typealias OffsetPair = (last: CGFloat, current: CGFloat)
        let pair: OffsetPair = (base.contentOffset.y, base.contentOffset.y)
        
        return didScroll
            .asObservable()
            .filter { [base = base] _ in !base.isBouncing }
            .scan(pair) { [base = base] pair, _ -> OffsetPair in
                (pair.current, base.contentOffset.y)
            }
            .filter { $0.last != $0.current }
            .map {
                if $0.last > $0.current {
                    return .up
                } else {
                    return .down
                }
            }
    }
}
