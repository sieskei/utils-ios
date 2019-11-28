//
//  FastAnimator.swift
//  FastAnimator
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
// @class FastAnimator
// @abstract FastAnimator
// @discussion FastAnimator
//

import UIKit

public class FastAnimator: UIView, CRRefreshProtocol {
    
    public var view: UIView { return self }
    
    public var insets: UIEdgeInsets = .zero
    
    public var trigger: CGFloat = 55.0
    
    public var execute: CGFloat = 55.0
    
    public var endDelay: CGFloat = 1
    
    public var hold: CGFloat = 55.0
    
    private(set) var color: UIColor = .init(rgb: (214, 214, 214))
    
    private(set) var arrowColor: UIColor = .init(rgb: (165, 165, 165))
    
    private(set) var lineWidth: CGFloat = 1
    
    private(set) lazy var fastLayer: FastLayer? = {
        let width  = frame.width
        let height = frame.height
        let layerFrame: CGRect = .init(x: width/2 - 14, y: height/2 - 14, width: 28, height: 28)
        
        let fastLayer = FastLayer(frame: layerFrame, color: color, arrowColor: arrowColor, lineWidth: lineWidth)
        layer.addSublayer(fastLayer)
        
        return fastLayer
    }()


    //MARK: CRRefreshProtocol
    /// 开始刷新
    public func refreshBegin(view: CRRefreshComponent) {
        fastLayer?.arrow?.startAnimation().animationEnd = { [weak self] in
            self?.fastLayer?.circle?.startAnimation()
        }
    }
    
    /// 结束刷新
    public func refreshEnd(view: CRRefreshComponent, finish: Bool) {
        if finish {
            fastLayer?.arrow?.endAnimation()
            fastLayer?.circle?.endAnimation(finish: finish)
        }
    }
    
    public func refreshWillEnd(view: CRRefreshComponent) {
        fastLayer?.circle?.endAnimation(finish: false)
    }
    
    public func refreshWillEnd(view: CRRefreshComponent, with completion: @escaping () -> Void) {
        fastLayer?.circle?.check?.animationEnd = completion
        fastLayer?.circle?.endAnimation(finish: false)
    }
    
    /// 刷新进度的变化
    public func refresh(view: CRRefreshComponent, progressDidChange progress: CGFloat) {
        
    }
    
    /// 刷新状态的变化
    public func refresh(view: CRRefreshComponent, stateDidChange state: CRRefreshState) {
        
    }
    
    //MARK: Override
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    public override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        guard layer == self.layer, let fastLayer = fastLayer else { return }
        fastLayer.frame.origin = .init(x: frame.width/2 - 14, y: frame.height/2 - 14)
    }
    
    //MARK: Initial Methods
   public init(frame: CGRect, color: UIColor = .init(rgb: (214, 214, 214)), arrowColor: UIColor = .init(rgb: (165, 165, 165)), lineWidth: CGFloat = 1) {
        self.color      = color
        self.arrowColor = arrowColor
        self.lineWidth  = lineWidth
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
