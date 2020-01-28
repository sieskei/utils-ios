//
//  FastCheckLayer.swift
//
//  Created by Miroslav Yozov on 14.05.18.
//  Copyright © 2018 Net Info.BG EAD. All rights reserved.
//

import UIKit

class FastCheckLayer: CALayer, CAAnimationDelegate {
    private (set) lazy var check: CAShapeLayer = {
        let layer = CAShapeLayer()
        
        layer.lineCap   = .round
        layer.lineJoin  = .round
        layer.lineWidth = lineWidth
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = color.cgColor
        layer.strokeStart = 0
        layer.strokeEnd = 0
        
        let path = UIBezierPath()
        let width = Double(frame.size.width)
        
        let a = sin(0.4) * (width/2)
        let b = cos(0.4) * (width/2)
        path.move(to: CGPoint.init(x: width/2 - b, y: width/2 - a))
        path.addLine(to: CGPoint.init(x: width/2 - width/20 , y: width/2 + width/8))
        path.addLine(to: CGPoint.init(x: width - width/5, y: width/2 - a))
        layer.path = path.cgPath
        
        return layer
    }()
    
    let color: UIColor
    
    let lineWidth: CGFloat
    
    var animationEnd: (() -> Void)?
    
    //MARK: Public Methods
    @discardableResult
    func startAnimation() -> Self {
        let start = CAKeyframeAnimation(keyPath: "strokeStart")
        start.values = [0, 0.4, 0.3]
        start.isRemovedOnCompletion = false
        start.fillMode = .forwards
        start.duration = 0.3125
        start.timingFunction = .init(name: .easeInEaseOut)
        
        let end = CAKeyframeAnimation(keyPath: "strokeEnd")
        end.values = [0, 1, 0.9]

        end.isRemovedOnCompletion = false
        end.fillMode = .forwards
        end.duration = 0.5
        end.timingFunction = .init(name: .easeInEaseOut)
        end.delegate = self
        
        check.add(start, forKey: "start")
        check.add(end, forKey: "end")
        
        return self
    }
    
    func endAnimation() {
        check.removeAllAnimations()
    }
    
    //MARK: Initial Methods
    init(frame: CGRect, color: UIColor = .init(rgb: (165, 165, 165)), lineWidth: CGFloat = 1) {
        self.color      = color
        self.lineWidth  = lineWidth * 2
        super.init()
        self.frame      = frame
        backgroundColor = UIColor.clear.cgColor
        
        addSublayer(check)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animationEnd?()
    }
}
