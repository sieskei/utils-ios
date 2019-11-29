//
//  FastArrowLayer.swift
//
//  Created by Miroslav Yozov on 14.05.18.
//  Copyright © 2018 Net Info.BG EAD. All rights reserved.
//

import UIKit

class FastArrowLayer: CALayer, CAAnimationDelegate {
    private let animationDuration: Double = 0.2
    private var started = false
    
    var animationEnd: (()->Void)?
    
    let color: UIColor
    let lineWidth: CGFloat
    
    private lazy var lineLayer: CAShapeLayer = {
        let width  = frame.size.width
        let height = frame.size.height
        
        let path = UIBezierPath()
        path.move(to: .init(x: width/2, y: 0))
        path.addLine(to: .init(x: width/2, y: height/2 + height/3))
        
        let layer = CAShapeLayer()
        layer.lineWidth   = lineWidth * 2
        layer.strokeColor = color.cgColor
        layer.fillColor   = UIColor.clear.cgColor
        layer.lineCap     = CAShapeLayerLineCap.round
        layer.path        = path.cgPath
        layer.strokeStart = 0.5
        
        return layer
    }()
    
    private lazy var arrowLayer: CAShapeLayer = {
        let width  = frame.size.width
        let height = frame.size.height
        
        let path = UIBezierPath()
        path.move(to: .init(x: width/2 - height/6, y: height/2 + height/6))
        path.addLine(to: .init(x: width/2, y: height/2 + height/3))
        path.addLine(to: .init(x: width/2 + height/6, y: height/2 + height/6))
        
        let layer = CAShapeLayer()
        layer.lineWidth   = lineWidth * 2
        layer.strokeColor = color.cgColor
        layer.lineCap     = CAShapeLayerLineCap.round
        layer.lineJoin    = CAShapeLayerLineJoin.round
        layer.fillColor   = UIColor.clear.cgColor
        layer.path        = path.cgPath
        
        return layer
    }()
    
    //MARK: Initial Methods
    init(frame: CGRect, color: UIColor = .init(rgb: (165, 165, 165)), lineWidth: CGFloat = 1) {
        self.color      = color
        self.lineWidth  = lineWidth
        super.init()
        self.frame      = frame
        backgroundColor = UIColor.clear.cgColor
        
        addSublayer(lineLayer)
        addSublayer(arrowLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        arrowLayer.add(start, forKey: "strokeStart")
        arrowLayer.add(end, forKey: "strokeEnd")
        
        return self
    }

    func endAnimation() {
        arrowLayer.isHidden = false
        lineLayer.isHidden  = false
        
        arrowLayer.removeAllAnimations()
        lineLayer.removeAllAnimations()
    }

    private func addLineAnimation() {
        let start = CABasicAnimation(keyPath: "strokeStart")
        start.fromValue = 0.5
        start.toValue = 0
        start.isRemovedOnCompletion = false
        start.fillMode  = CAMediaTimingFillMode.forwards
        start.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        start.duration  = animationDuration / 2
        lineLayer.add(start, forKey: "strokeStart")
        
        let end = CABasicAnimation(keyPath: "strokeEnd")
        end.beginTime = CACurrentMediaTime() + animationDuration/3
        end.duration  = animationDuration / 2
        end.fromValue = 1
        end.toValue   = 0.03
        end.isRemovedOnCompletion = false
        end.fillMode  = CAMediaTimingFillMode.forwards
        end.delegate  = self
        end.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        lineLayer.add(end, forKey: "strokeEnd")
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
            arrowLayer.isHidden = true
            addLineAnimation()
        case "strokeEnd":
            lineLayer.isHidden = true
            animationEnd?()
            
            started = false
        default:
            print("Unknown animation: \(anim).")
        }
    }
}
