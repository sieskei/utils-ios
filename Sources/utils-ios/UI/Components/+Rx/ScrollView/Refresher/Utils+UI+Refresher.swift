//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 20.07.22.
//

import UIKit
import RxSwift

extension Utils.UI {
    internal struct ScrollRefresher { }
}

// MARK: - Refresher UI view
extension Utils.UI.ScrollRefresher {
    final class View: Utils.UI.View {
        struct Constants {
            static let trigger   : CGFloat = 44
            static let height    : CGFloat = 44
            static let lineWidth : CGFloat = 1
            
            static var color      : UIColor = .blue
            static var arrowColor : UIColor = .black
            
            static let layerSize     : CGFloat = 28
            static var layerHalfSize : CGFloat {
                return layerSize / 2
            }
        }
        
        class Owner { }
        
        var scrollView: UIScrollView? {
            superview as? UIScrollView
        }
        
        let owner: Owner = .init()
        let action: UtilsUIScrollRefresher.Action
        
        private var disposeBag: DisposeBag = .init()
        
        init(action: @escaping UtilsUIScrollRefresher.Action) {
            self.action = action
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private lazy var fastLayer: FastLayer = {
            let width  = frame.width
            let height = frame.height
            let layerFrame: CGRect = .init(x: width/2 - Constants.layerHalfSize, y: height/2 - Constants.layerHalfSize,
                                           width: Constants.layerSize, height: Constants.layerSize)
            
            let fastLayer: FastLayer = .init()
            fastLayer.prepare(frame: layerFrame, color: Constants.color, arrowColor: Constants.arrowColor, lineWidth: Constants.lineWidth)
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
            .init(object: self, keyPath: \.refreshingFlag)
        }()
        
        // When 'true' ignore scrollview's content offset changes during start/stop animation.
        private var stopObserving = false
        
        // When 'true' animation is started, prevent from double start.
        private var isRefreshing = false
        
        // When 'true' STOPPING animation is started, prevent from double stop.
        private var isRefreshStopping = false
        
        override func prepare() {
            super.prepare()
            backgroundColor = .clear
        }
        
        override func layoutSublayers(of layer: CALayer) {
            super.layoutSublayers(of: layer)
            guard layer == self.layer else { return }
            fastLayer.frame.origin = .init(x: frame.width/2 - 14, y: frame.height/2 - 14)
        }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            super.willMove(toSuperview: newSuperview)
            
            disposeBag = .init()
            
            guard let view = newSuperview as? UIScrollView else {
                return
            }
            
            view.rx.contentOffset
                .observe(on: MainScheduler.asyncInstance)
                .distinctUntilChanged()
                .withUnretained(self)
                .ignoreWhen { this, _ in
                    this.stopObserving
                }
                .subscribe(onNext: { this, point in
                    if !this.isRefreshing {
                        this.alpha = min(-(point.y + view.contentInset.top) / Constants.trigger, 1)
                    }
                    
                    if point.y + view.contentInset.top < -Constants.trigger {
                        if !view.isDragging {
                            this.doStart(programmatically: false)
                        }
                    }
                })
                .disposed(by: disposeBag)
        }
        
        func doStart(programmatically: Bool) {
            guard !isRefreshing else { return }
            isRefreshing = true
            
            guard let scrollView = scrollView else { return }
            
            stopObserving = true
            
            if !programmatically {
                fastLayer.arrow.start { [weak self] in
                    self?.fastLayer.circle.start()
                }
            }
            
            let animations: () -> Void = {
                scrollView.contentInset.top += Constants.height
                if scrollView.contentOffset.y <= scrollView.contentInset.top {
                    scrollView.contentOffset.y = -scrollView.contentInset.top
                }
                self.alpha = 1.0
            }
            
            let completion: (Bool) -> Void = { _ in
                defer {
                    self.stopObserving = false
                }
                
                if programmatically {
                    self.fastLayer.arrow.start { [weak self] in
                        self?.fastLayer.circle.start()
                    }
                }
                
                if !programmatically {
                    let token = self.start(by: self.owner, delay: .seconds(.zero))
                    self.action(self, self.owner, token)
                }
            }
            // do not layout / animate if scrollview is not in view hierarchy
            if scrollView.window != nil {
                scrollView.layoutIfNeeded()
                UIView.transition(with: scrollView, duration: 0.25, options: [.curveLinear, .beginFromCurrentState, .layoutSubviews],  animations: {
                    animations()
                    // only if stil in view hierarchy
                    if scrollView.window != nil {
                        scrollView.layoutIfNeeded()
                    }
                }, completion: completion)
            } else {
                animations()
                DispatchQueue.main.async {
                    completion(true)
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
            
            fastLayer.circle.check.completion = { [weak self, weak scrollView] in
                guard let this = self else { return }
                
                // this.fastLayer.circle.stop(finish: false)
                
                let completion: (Bool) -> Void = { _ in
                    defer {
                        this.stopObserving = false
                        
                        this.isRefreshing = false
                        this.isRefreshStopping = false
                    }
                    
                    this.fastLayer.arrow.stop()
                    this.fastLayer.circle.stop(finish: true)
                }
                
                guard let scrollView = scrollView else {
                    completion(false)
                    return
                }
                
                let animations: () -> Void = {
                    scrollView.contentInset.top -= Constants.height
                    this.alpha = 0.0
                }
                
                // do not layout / animate if scrollview is not in view hierarchy
                if scrollView.window != nil {
                    scrollView.layoutIfNeeded()
                    UIView.transition(with: scrollView, duration: 0.25, options: [.curveLinear, .beginFromCurrentState, .layoutSubviews],  animations: {
                        animations()
                        // only if stil in view hierarchy
                        if scrollView.window != nil {
                            scrollView.layoutIfNeeded()
                        }
                    }, completion: completion)
                } else {
                    animations()
                    DispatchQueue.main.async {
                        completion(true)
                    }
                }
            }
            
            fastLayer.circle.stop(finish: false)
        }
        
        func start() {
            refreshingCount++
        }
        
        func stop() {
            refreshingCount--
        }
        
        deinit {
            Utils.Log.debug("deinit ...", self)
            
            if let view = scrollView {
                view.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
            }
        }
    }
}

extension Utils.UI.ScrollRefresher.View: UtilsUIScrollRefresher {
    struct AssociatedKeys {
        static var meta: UInt8 = 0
    }
    
    private class Meta {
        weak var view: Utils.UI.ScrollRefresher.View?
        
        private var delayedTokens: Set<String> = []
        private var tokens: Set<String> = [] {
            didSet {
                guard let r = view, oldValue.isEmpty != tokens.isEmpty else {
                    return
                }
                
                if tokens.isEmpty {
                    r.stop()
                } else {
                    r.start()
                }
            }
        }
        
        init(_ r: Utils.UI.ScrollRefresher.View) {
            view = r
        }
        
        func plus(_ delay: DispatchTimeInterval) -> String {
            let token = UUID().uuidString
            if delay.isZero {
                tokens.insert(token)
            } else {
                delayedTokens.insert(token)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                    guard let this = self else {
                        return
                    }
                    
                    if let token = this.delayedTokens.remove(token) {
                        this.tokens.insert(token)
                    }
                }
            }
            
            return token
        }
        
        func minus(_ token: String) {
            if delayedTokens.remove(token) == nil {
                tokens.remove(token)
            }
        }
        
        deinit {
            view ~> {
                $0.stop()
            }
        }
    }
    
    func start(by object: AnyObject, delay: DispatchTimeInterval) -> String {
        Utils.Task.guard(object) {
            let meta: Meta = Utils.AssociatedObject.get(base: object, key: &AssociatedKeys.meta) { .init(self) }
            return meta.plus(delay)
        }
    }
    
    func stop(by object: AnyObject, token: String) {
        Utils.Task.guard(object) {
            if let meta: Meta = Utils.AssociatedObject.get(base: object, key: &AssociatedKeys.meta) {
                meta.minus(token)
            }
        }
    }
}
