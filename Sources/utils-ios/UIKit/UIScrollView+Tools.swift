//
//  UIScrollView+Tools.swift
//
//  Created by Miroslav Yozov on 14.05.18.
//  Copyright © 2018 Net Info.BG EAD. All rights reserved.
//

import UIKit

public protocol UIScrollViewPullToRefreshTool {
    func start(by object: AnyObject)
    func stop(by object: AnyObject)
}

fileprivate final class UIScrollViewPullToRefreshToolView: UIView {
    struct Constants {
        static let trigger   : CGFloat = 44
        static let height    : CGFloat = 44
        static let lineWidth : CGFloat = 1
        
        static let color      : UIColor = .blue
        static let arrowColor : UIColor = .black
        
        static let layerSize     : CGFloat = 28
        static var layerHalfSize : CGFloat {
            return layerSize / 2
        }
    }
    
    private var KVOContext = 0
    
    var scrollView: UIScrollView? {
        return superview as? UIScrollView
    }
    
    var handler: (() -> Void)?
    
    private lazy var fastLayer: FastLayer = {
        let width  = frame.width
        let height = frame.height
        let layerFrame: CGRect = .init(x: width/2 - Constants.layerHalfSize, y: height/2 - Constants.layerHalfSize,
                                       width: Constants.layerSize, height: Constants.layerSize)
        
        let fastLayer = FastLayer(frame: layerFrame, color: Constants.color, arrowColor: Constants.arrowColor, lineWidth: Constants.lineWidth)
        layer.addSublayer(fastLayer)
        
        return fastLayer
    }()
    
    // When 'true' start refreshing programmatically.
    private var refreshingFlag = false {
        didSet {
            guard refreshingFlag != oldValue else { return }
            
            if refreshingFlag {
                doStart(programmatically: true)
            } else {
                doStop()
            }
        }
    }
    
    private lazy var refreshingCount: BoolCounter = {
        return BoolCounter(object: self, keyPath: \UIScrollViewPullToRefreshToolView.refreshingFlag)
    }()
    
    // When 'true' ignore scrollview's content offset changes during start/stop animation.
    private var stopObserving = false
    
    // When 'true' animation is started, prevent from double start.
    private var isRefreshing = false
    
    // When 'true' STOPPING animation is started, prevent from double stop.
    private var isRefreshStopping = false
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        guard layer == self.layer else { return }
        fastLayer.frame.origin = .init(x: frame.width/2 - 14, y: frame.height/2 - 14)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if let view = scrollView {
            view.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
        }
        
        if let view = newSuperview as? UIScrollView {
            view.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [.old], context: &KVOContext)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &KVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        guard let scrollView = object as? UIScrollView, scrollView == self.scrollView, !stopObserving else { return }
        
        if keyPath == #keyPath(UIScrollView.contentOffset) {
            guard let oldOffset = change?[.oldKey] as? CGPoint, scrollView.contentOffset != oldOffset else {
                return
            }
            
            if !isRefreshing {
                self.alpha = min(-(scrollView.contentOffset.y + scrollView.contentInset.top) / Constants.trigger, 1)
            }
            
            if scrollView.contentOffset.y + scrollView.contentInset.top < -Constants.trigger {
                if !scrollView.isDragging {
                    doStart(programmatically: false)
                }
            }
        }
    }
    
    func doStart(programmatically: Bool) {
        guard !isRefreshing else { return }
        isRefreshing = true
        
        guard let scrollView = scrollView else { return }
        
        stopObserving = true
        
        if !programmatically {
            fastLayer.arrow.startAnimation().animationEnd = { [weak self] in
                self?.fastLayer.circle.startAnimation()
            }
        }
        
        scrollView.layoutIfNeeded()
        UIView.transition(with: scrollView, duration: 0.25, options: [.curveLinear, .beginFromCurrentState, .layoutSubviews],  animations: {
            defer {
                self.alpha = 1.0
                scrollView.layoutIfNeeded()
            }
            
            scrollView.contentInset.top += Constants.height
            if scrollView.contentOffset.y <= scrollView.contentInset.top {
                scrollView.contentOffset.y = -scrollView.contentInset.top
            }
        }) { _ in
            defer {
                self.stopObserving = false
            }
            
            if programmatically {
                self.fastLayer.arrow.startAnimation().animationEnd = { [weak self] in
                    self?.fastLayer.circle.startAnimation()
                }
            }
            
            if !programmatically {
                self.handler?()
            }
        }
    }
    
    func doStop() {
        guard isRefreshing, !isRefreshStopping else {
            return
        }
        
        guard let scrollView = scrollView else {
            isRefreshing = false
            return
        }
        
        isRefreshStopping = true
        stopObserving = true
        
        fastLayer.circle.check.animationEnd = { [weak self, weak scrollView] in
            guard let this = self else { return }
            
            this.fastLayer.circle.endAnimation(finish: false)
            
            let completion: (Bool) -> Void = { _ in
                defer {
                    this.stopObserving = false
                    
                    this.isRefreshing = false
                    this.isRefreshStopping = false
                }
                
                this.fastLayer.arrow.endAnimation()
                this.fastLayer.circle.endAnimation(finish: true)
            }
            
            guard let scrollView = scrollView else {
                completion(false)
                return
            }
            
            scrollView.layoutIfNeeded()
            UIView.transition(with: scrollView, duration: 0.25, options: [.curveLinear, .beginFromCurrentState, .layoutSubviews],  animations: {
                defer {
                    this.alpha = 0.0
                    scrollView.layoutIfNeeded()
                }
                scrollView.contentInset.top -= Constants.height
            }, completion: completion)
        }
        
        fastLayer.circle.endAnimation(finish: false)
    }
    
    func start() {
        refreshingCount++
    }
    
    func stop() {
        refreshingCount--
    }
    
    deinit {
        print(self, "deinit ...")
        
        if let view = scrollView {
            view.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
        }
    }
}

extension UIScrollViewPullToRefreshToolView: UIScrollViewPullToRefreshTool {
    struct AssociatedKeys {
        static var meta: UInt8 = 0
    }
    
    class RequestMeta {
        weak var pullToRefresh: UIScrollViewPullToRefreshToolView?
        private var counter: Int = 0 {
            didSet {
                guard let pullToRefresh = pullToRefresh else {
                    return
                }
                
                if oldValue == 0, counter == 1 {
                    pullToRefresh.start()
                } else if oldValue > 0, counter == 0 {
                    pullToRefresh.stop()
                }
            }
        }
        
        func plus() {
            counter += 1
        }
        
        func minus() {
            if counter > 0 {
                counter -= 1
            }
        }
        
        deinit {
            guard let pullToRefresh = pullToRefresh else {
                return
            }
            
            pullToRefresh.stop()
        }
    }
    
    // ---------------- //
    // MARK: Public API //
    // ---------------- //
    
    func start(by object: AnyObject) {
        objc_sync_enter(object)
        defer {
            objc_sync_exit(object)
        }
        
        let meta: RequestMeta
        if let current = objc_getAssociatedObject(object, &AssociatedKeys.meta) as? RequestMeta {
            meta = current
        } else {
            meta = .init()
            meta.pullToRefresh = self
            objc_setAssociatedObject(object, &AssociatedKeys.meta, meta, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        meta.plus()
    }
    
    func stop(by object: AnyObject) {
        objc_sync_enter(object)
        defer {
            objc_sync_exit(object)
        }
        
        if let meta = objc_getAssociatedObject(object, &AssociatedKeys.meta) as? RequestMeta {
            meta.minus()
        }
    }
}

fileprivate extension UIScrollView {
    struct AssociatedKeys {
        static var pullToRefresh: UInt8 = 0
    }
}

public extension UIScrollView {
    private var refresherView: UIScrollViewPullToRefreshToolView? {
        return subviews.first { $0 is UIScrollViewPullToRefreshToolView } as? UIScrollViewPullToRefreshToolView
    }
    
    struct Tools {
        public var pullToRefresh: UIScrollViewPullToRefreshTool? {
            return scrollView.refresherView
        }
        
        public let scrollView: UIScrollView
        
        @discardableResult
        public func pullToRefresh(with action: @escaping () -> Void) -> UIScrollViewPullToRefreshTool {
            if let view = scrollView.refresherView {
                view.handler = action
                return view
            }
            
            let view = UIScrollViewPullToRefreshToolView()
            view.handler = action
            
            let height = UIScrollViewPullToRefreshToolView.Constants.height
            let width = scrollView.bounds.size.width
            view.frame = .init(x: 0, y: -height, width: width, height: height)
            view.autoresizingMask = [view.autoresizingMask, .flexibleWidth ]
            view.alpha = 0.0
            
            scrollView.addSubview(view)
            return view
        }
        
        public func removePullToRefresh() { }
    }
}

public extension UIScrollView {
    var tools: Tools {
        return Tools(scrollView: self)
    }
}
