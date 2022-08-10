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
    
    public enum HorizontalDirection: Int {
        case left
        case right
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
    private typealias OffsetPair = (last: CGFloat, current: CGFloat)
    
    private func source(keyPath path: KeyPath<CGPoint, CGFloat>) -> Observable<OffsetPair> {
        let offset = base.contentOffset
        return didScroll
            .asObservable()
            .filter { [base = base] _ in !base.isBouncing }
            .scan((offset[keyPath: path], offset[keyPath: path])) { [base = base] pair, _ -> (OffsetPair) in
                (pair.current, base.contentOffset[keyPath: path])
            }
            .filter { $0.last != $0.current }
    }
    
    public var didScrollVertically: Observable<UIScrollView.VerticalDirection> {
        source(keyPath: \CGPoint.y)
            .map { $0.last > $0.current ? .up : .down }
    }
    
    public var didScrollHorizontally: Observable<UIScrollView.HorizontalDirection> {
        source(keyPath: \CGPoint.x)
            .map { $0.last > $0.current ? .left : .right }
    }
}
