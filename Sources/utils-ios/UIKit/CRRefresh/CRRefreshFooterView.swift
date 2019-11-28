//
//  CRRefreshFooterView.swift
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
// @class CRRefreshFooterView
// @abstract 刷新的尾部控件
// @discussion 刷新的尾部控件
//

import UIKit

open class CRRefreshFooterView: CRRefreshComponent {
    private var noModeData = false {
        didSet {
            guard noModeData != oldValue else { return }
            
            if noModeData {
                if state == .idle {
                    state = .noMoreData
                }
            } else {
                if state == .noMoreData {
                    state = .idle
                }
            }
        }
    }
    
    open override var state: CRRefreshState {
        didSet {
            guard state != oldValue else { return }
            isHidden = state == .noMoreData
        }
    }
    
    open override var isHidden: Bool {
        didSet {
            guard isHidden != oldValue else { return }
            
            scrollView?.contentInset.bottom = self.isHidden ? self.scrollViewInsets.bottom : self.scrollViewInsets.bottom + self.animator.execute
            
            
            if isHidden {
                frame.size.height = 0
                frame.origin.y = scrollView?.contentSize.height ?? 0.0
            } else {
                frame.size.height = animator.execute
                frame.origin.y = scrollView?.contentSize.height ?? 0.0
            }
        }
    }
    
    public convenience init(animator: CRRefreshProtocol = NormalFooterAnimator(), handler: @escaping CRRefreshHandler) {
        self.init(frame: .zero)
        self.clipsToBounds = true
        
        self.handler  = handler
        self.animator = animator
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.scrollViewInsets = weakSelf.scrollView?.contentInset ?? UIEdgeInsets.zero
            weakSelf.scrollView?.contentInset.bottom = weakSelf.scrollViewInsets.bottom + weakSelf.bounds.size.height
            var rect = weakSelf.frame
            rect.origin.y = weakSelf.scrollView?.contentSize.height ?? 0.0
            weakSelf.frame = rect
        }
    }
    
    open override func start(manual: Bool) {
        guard let scrollView = scrollView else { return }
        
        super.start(manual: manual)
        animator.refreshBegin(view: self)
        
        let x = scrollView.contentOffset.x
        let y = max(0.0, scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        UIView.animate(withDuration: 0.25 /* CRRefreshComponent.animationDuration */, delay: 0.0, options: .curveLinear, animations: {
            scrollView.contentOffset = .init(x: x, y: y)
        }, completion: { (animated) in
            if !manual {
                self.handler?()
            }
        })
    }
    
    open override func stop() {
        guard let scrollView = scrollView else { return }

//        self.state = self.noModeData ? .noMoreData : .idle
//        super.stop()
//        self.animator.refreshEnd(view: self, finish: true)
        
        
        animator.refreshEnd(view: self, finish: false)
        let x = scrollView.contentOffset.x
        let y = max(0.0, scrollView.contentOffset.y - animator.execute)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
            scrollView.contentOffset = .init(x: x, y: y)
        }, completion: { (finished) in
            self.animator.refreshEnd(view: self, finish: true)
            super.stop()
            
            
            self.state = self.noModeData ? .noMoreData : .idle
        })
        
//        if scrollView.isDecelerating {
//            var contentOffset = scrollView.contentOffset
//            contentOffset.y = min(contentOffset.y, scrollView.contentSize.height - scrollView.frame.size.height)
//            if contentOffset.y < 0.0 {
//                contentOffset.y = 0.0
//                UIView.animate(withDuration: 4, animations: {
//                    scrollView.setContentOffset(contentOffset, animated: false)
//                })
//            } else {
//                scrollView.setContentOffset(contentOffset, animated: true)
//            }
//
//
//            // scrollView.setContentOffset(contentOffset, animated: true)
//        }
    }
    
    open override func sizeChange(change: [NSKeyValueChangeKey : Any]?) {
        guard let scrollView = scrollView else { return }
        super.sizeChange(change: change)
        let targetY = scrollView.contentSize.height + scrollViewInsets.bottom
        if self.frame.origin.y != targetY {
            var rect = self.frame
            rect.origin.y = targetY
            self.frame = rect
        }
    }
    
    open override func offsetChange(change: [NSKeyValueChangeKey : Any]?) {
        guard let scrollView = scrollView else { return }
        super.offsetChange(change: change)
        guard isRefreshing == false && state == .idle && isHidden == false else {
            // 正在loading more或者内容为空时不相应变化
            return
        }
        
        if scrollView.contentSize.height + scrollView.contentInset.top > scrollView.bounds.size.height {
            // 内容超过一个屏幕 计算公式，判断是不是在拖在到了底部
            if scrollView.contentSize.height - scrollView.contentOffset.y + scrollView.contentInset.bottom  <= scrollView.bounds.size.height {
                state = .refreshing
                beginRefreshing(manual: false)
            }
        } else {
            //内容没有超过一个屏幕，这时拖拽高度大于1/2footer的高度就表示请求上拉
            if scrollView.contentOffset.y + scrollView.contentInset.top >= animator.trigger / 2.0 {
                state = .refreshing
                beginRefreshing(manual: false)
            }
        }
    }
    
    open func setNoMoreData(to flag: Bool) {
        noModeData = flag
        if flag {
            endRefreshing()
        }
    }
}
