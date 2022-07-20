//
//  FastCheckLayer.swift
//
//  Created by Miroslav Yozov on 14.05.18.
//  Copyright © 2018 Net Info.BG EAD. All rights reserved.
//

import UIKit

extension Utils.UI.ScrollRefresher {
    class FastCheckLayer: CALayer, CAAnimationDelegate {
        private var check: CAShapeLayer {
            guard let layers = sublayers, layers.count == 1 else {
                fatalError("Missing sublayers!")
            }
            return Utils.castOrFatalError(layers[0])
        }
        
        //MARK: Public Methods
        @discardableResult
        func start() -> Self {
            guard !started else {
                return self
            }
            
            started = true
            
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
        
        func stop() {
            guard started else {
                return
            }
            
            started = false
            check.removeAllAnimations()
        }
        
        func prepare(frame: CGRect, color: UIColor = .init(rgb: (165, 165, 165)), lineWidth: CGFloat = 1) {
            self.frame = frame
            self.backgroundColor = UIColor.clear.cgColor
            
            addSublayer({
                let layer = CAShapeLayer()

                layer.lineCap   = .round
                layer.lineJoin  = .round
                layer.lineWidth = lineWidth * 2
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
            }())
        }
        
        func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
            completion?()
        }
    }
}

extension Utils.UI.ScrollRefresher.FastCheckLayer: AssociatedObjectCompatible {
    class Props {
        var started: Bool = false
        var completion: (()->Void)? = nil
    }
    
    private var props: Props {
        return get(for: "props") { .init() }
    }
    
    var started: Bool {
        get { props.started }
        set { props.started = newValue }
    }
    
    var completion: (()->Void)? {
        get { props.completion }
        set { props.completion = newValue }
    }
}
