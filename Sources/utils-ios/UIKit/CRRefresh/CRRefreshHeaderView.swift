//
//  CRRefreshHeaderView.swift
//  CRRefresh
//
// **************************************************
// *                                  _____         *
// *         __  _  __     ___        \   /         *
// *         \ \/ \/ /    / __\       /  /          *
// *          \  _  /    | (__       /  /           *
// *           \/ \/      \___/     /  /__          *
// *                               /_____/          *
// *                                                *
// **************************************************
//  Github  :https://github.com/imwcl
//  HomePage:http://imwcl.com
//  CSDN    :http://blog.csdn.net/wang631106979
//
//  Created by 王崇磊 on 16/9/14.
//  Copyright © 2016年 王崇磊. All rights reserved.
//
// @class CRRefreshHeaderView
// @abstract 刷新的头部控件
// @discussion 刷新的头部控件
//

import UIKit

open class CRRefreshHeaderView: CRRefreshComponent {
    
    /// 记录之前的offsetY
    fileprivate var previousOffsetY: CGFloat = 0.0
    fileprivate var scrollViewBounces: Bool  = true
    /// 记录结束刷新时需要调整的contentInsetY
    fileprivate var insetTDelta: CGFloat     = 0.0
    /// 记录悬停时需要调整的contentInsetY
    fileprivate var holdInsetTDelta: CGFloat = 0.0
    
    public convenience init(animator: CRRefreshProtocol = NormalHeaderAnimator(), handler: @escaping CRRefreshHandler) {
        self.init(frame: .zero)
        self.handler  = handler
        self.animator = animator
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        scrollViewBounces = scrollView?.bounces ?? false
    }
    
    open override func start(manual: Bool) {
        guard let scrollView = scrollView else { return }
        // 动画的时候先忽略监听
        ignoreObserver(true)
        
        scrollView.bounces = false
        
        
        if !manual {
            super.start(manual: manual)
            // 开始动画
            self.animator.refreshBegin(view: self)
        }
        
        // 调整scrollView的contentInset
        var insets           = scrollView.contentInset
        scrollViewInsets.top = insets.top
        insets.top          += animator.execute
        insetTDelta          = -animator.execute
        holdInsetTDelta      = -(animator.execute - animator.hold)
        UIView.animate(withDuration: 3, animations: {
            scrollView.contentOffset.y = self.previousOffsetY
            scrollView.contentInset    = insets
            if self.previousOffsetY <= insets.top {
                scrollView.contentOffset.y = -insets.top
            }
        }) { (finished) in
            if manual {
                super.start(manual: manual)
                // 开始动画
                self.animator.refreshBegin(view: self)
            }

            DispatchQueue.main.async {
                if !manual {
                    self.handler?()
                }

                self.ignoreObserver(false)
                scrollView.bounces = self.scrollViewBounces
            }
        }
    }
    
    open override func stop() {
        guard let scrollView = scrollView else { return }
        // 动画的时候先忽略监听
        ignoreObserver(true)
        
        func finishStop() {
            // 结束动画
            animator.refreshEnd(view: self, finish: false)
            
            // 调整scrollView的contentInset
            UIView.animate(withDuration: 3, animations: {
                scrollView.contentInset.top += self.insetTDelta - self.holdInsetTDelta
            }) { (finished) in
                DispatchQueue.main.async {
                    self.state = .idle
                    super.stop()
                    
                    self.animator.refreshEnd(view: self, finish: true)
                    self.ignoreObserver(false)
                }
            }
        }
        
        animator.refreshWillEnd(view: self) {
            finishStop()
        }
        
        if self.animator.hold != 0 {
            UIView.animate(withDuration: CRRefreshComponent.animationDuration) {
                scrollView.contentInset.top += self.holdInsetTDelta
            }
        }
    }

    open override func offsetChange(change: [NSKeyValueChangeKey : Any]?) {
        guard let scrollView = scrollView else { return }
        super.offsetChange(change: change)
        // sectionheader停留的解决方案
        guard isRefreshing == false else {
            if self.window == nil {return}
            
            let top          = scrollViewInsets.top
            let offsetY      = scrollView.contentOffset.y
            let height       = frame.size.height
            var scrollingTop = (-offsetY > top) ? -offsetY : top
            scrollingTop     = (scrollingTop > height + top) ? (height + top) : scrollingTop
            scrollView.contentInset.top = scrollingTop
            insetTDelta      = scrollViewInsets.top - scrollingTop
            return
        }
        
        // 算出Progress
        var isRecordingProgress = false
        defer {
            if isRecordingProgress == true {
                let percent = -(previousOffsetY + scrollViewInsets.top) / animator.trigger
                animator.refresh(view: self, progressDidChange: percent)
            }
        }
        
        let offsets = previousOffsetY + scrollViewInsets.top
        if offsets < -animator.trigger {
            if isRefreshing == false {
                if scrollView.isDragging == false, state == .pulling {
                    beginRefreshing(manual: false)
                    state = .refreshing
                } else {
                    state = .pulling
                    isRecordingProgress = true
                }
            }
        } else if offsets < 0 {
            if isRefreshing == false {
                state = .idle
                isRecordingProgress = true
            }
        }
        previousOffsetY = scrollView.contentOffset.y
    }
}
