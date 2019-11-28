//
//  FastArrowLayer.swift
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
//  HomePage:https://imwcl.com
//  CSDN    :http://blog.csdn.net/wang631106979
//
//  Created by 王崇磊 on 16/9/14.
//  Copyright © 2016年 王崇磊. All rights reserved.
//
// @class FastArrowLayer
// @abstract 箭头的layer
// @discussion 箭头的layer
//

import UIKit

class FastArrowLayer: CALayer,
                      CAAnimationDelegate {
    
    let color: UIColor
    
    let lineWidth: CGFloat
    
    private var lineLayer: CAShapeLayer?
    
    private var arrowLayer: CAShapeLayer?
    
    private let animationDuration: Double = 0.2
    
    var animationEnd: (()->Void)?
    
    private var started = false
    
    //MARK: Initial Methods
    init(frame: CGRect, color: UIColor = .init(rgb: (165, 165, 165)), lineWidth: CGFloat = 1) {
        self.color      = color
        self.lineWidth  = lineWidth
        super.init()
        self.frame      = frame
        backgroundColor = UIColor.clear.cgColor
        initLineLayer()
        initArrowLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Privater Methods
    private func initLineLayer() {
        let width  = frame.size.width
        let height = frame.size.height
        let path = UIBezierPath()
        path.move(to: .init(x: width/2, y: 0))
        path.addLine(to: .init(x: width/2, y: height/2 + height/3))
        lineLayer = CAShapeLayer()
        lineLayer?.lineWidth   = lineWidth*2
        lineLayer?.strokeColor = color.cgColor
        lineLayer?.fillColor   = UIColor.clear.cgColor
        lineLayer?.lineCap     = CAShapeLayerLineCap.round
        lineLayer?.path        = path.cgPath
        lineLayer?.strokeStart = 0.5
        addSublayer(lineLayer!)
    }
    
    private func initArrowLayer() {
        let width  = frame.size.width
        let height = frame.size.height
        let path = UIBezierPath()
        path.move(to: .init(x: width/2 - height/6, y: height/2 + height/6))
        path.addLine(to: .init(x: width/2, y: height/2 + height/3))
        path.addLine(to: .init(x: width/2 + height/6, y: height/2 + height/6))
        arrowLayer = CAShapeLayer()
        arrowLayer?.lineWidth   = lineWidth*2
        arrowLayer?.strokeColor = color.cgColor
        arrowLayer?.lineCap     = CAShapeLayerLineCap.round
        arrowLayer?.lineJoin    = CAShapeLayerLineJoin.round
        arrowLayer?.fillColor   = UIColor.clear.cgColor
        arrowLayer?.path        = path.cgPath
        addSublayer(arrowLayer!)
    }
    
    //MARK: public Methods
    @discardableResult
    func startAnimation() -> Self {
        guard !started else {
            return self
        }
        
        started = true
        
        let start = CABasicAnimation(keyPath: "strokeStart")
        start.duration  = animationDuration
        start.fromValue = 0
        start.toValue   = 0.5
        start.isRemovedOnCompletion = false
        start.fillMode  = CAMediaTimingFillMode.forwards
        start.delegate  = self
        start.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        let end = CABasicAnimation(keyPath: "strokeEnd")
        end.duration  = animationDuration
        end.fromValue = 1
        end.toValue   = 0.5
        end.isRemovedOnCompletion = false
        end.fillMode  = CAMediaTimingFillMode.forwards
        end.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        arrowLayer?.add(start, forKey: "strokeStart")
        arrowLayer?.add(end, forKey: "strokeEnd")
        
        return self
    }

    func endAnimation() {
        arrowLayer?.isHidden = false
        lineLayer?.isHidden  = false
        arrowLayer?.removeAllAnimations()
        lineLayer?.removeAllAnimations()
    }

    private func addLineAnimation() {
        let start = CABasicAnimation(keyPath: "strokeStart")
        start.fromValue = 0.5
        start.toValue = 0
        start.isRemovedOnCompletion = false
        start.fillMode  = CAMediaTimingFillMode.forwards
        start.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        start.duration  = animationDuration/2
        lineLayer?.add(start, forKey: "strokeStart")
        
        let end = CABasicAnimation(keyPath: "strokeEnd")
        end.beginTime = CACurrentMediaTime() + animationDuration/3
        end.duration  = animationDuration/2
        end.fromValue = 1
        end.toValue   = 0.03
        end.isRemovedOnCompletion = false
        end.fillMode  = CAMediaTimingFillMode.forwards
        end.delegate  = self
        end.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        lineLayer?.add(end, forKey: "strokeEnd")
    }
}

// --------------------- //
// MARK: CALayerDelegate //
// --------------------- //
extension FastArrowLayer: CALayerDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let anim = anim as? CABasicAnimation  else { return }
        
        switch anim.keyPath {
        case "strokeStart":
            arrowLayer?.isHidden = true
            addLineAnimation()
        case "strokeEnd":
            lineLayer?.isHidden = true
            animationEnd?()
            
            started = false
        default:
            print("Unknown animation: \(anim).")
        }
    }
}
