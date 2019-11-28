//
//  FastCircleLayer.swift
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
// @class FastCircleLayer
// @abstract 外层圆环的layer
// @discussion 外层圆环的layer
//

import UIKit

class FastCircleLayer: CALayer {
    
    let color: UIColor
    
    let pointColor: UIColor
    
    let lineWidth: CGFloat
    
    let circle = CAShapeLayer()
    
    let point  = CAShapeLayer()
        
    private let pointBack = CALayer()
    
    private var rotated: CGFloat = 0
    
    private var rotatedSpeed: CGFloat = 0
    
    private var speedInterval: CGFloat = 0
    
    private var stop: Bool = false
    
    private(set) var check: FastCheckLayer?
    
    var codeTimer: DispatchSourceTimer? {
        didSet {
            oldValue?.cancel()
            if let timer = codeTimer {
                timer.schedule(deadline: .now(), repeating: .milliseconds(48))
                timer.resume()
            }
        }
    }
    
    //MARK: Initial Methods
    init(frame: CGRect, color: UIColor = .init(rgb: (214, 214, 214)), pointColor: UIColor = .init(rgb: (165, 165, 165)), lineWidth: CGFloat = 1) {
        self.color      = color
        self.lineWidth  = lineWidth
        self.pointColor = pointColor
        pointBack.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        super.init()
        self.frame      = frame
        backgroundColor = UIColor.clear.cgColor
        pointBack.backgroundColor = UIColor.clear.cgColor
        drawCircle()
        addSublayer(pointBack)
        drawPoint()
        addCheckLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Public Methods
    func startAnimation() {
        circle.isHidden = false
        point.isHidden  = false
        
        let timer = DispatchSource.makeTimerSource(queue: .global())
        timer.setEventHandler { [weak self] in
            guard let this = self else { return }
            
            this.rotated = this.rotated - this.rotatedSpeed
            
            if this.stop {
                let count = Int(this.rotated / CGFloat(Double.pi * 2))
                
                if (CGFloat(Double.pi * 2 * Double(count)) - this.rotated) >= 1.1 {
                    let transform = CGAffineTransform.identity.rotated(by: -1.1)
                    DispatchQueue.main.async {
                        this.pointBack.setAffineTransform(transform)
                        this.point.isHidden = true
                        this.check?.startAnimation()
                    }
                    
                    this.codeTimer = nil
                    return
                }
                
                if this.rotatedSpeed < 0.175 {
                    this.rotatedSpeed = 0.175 // make it faster :)
                }
            }
            
            if this.rotatedSpeed < 0.35 {
                if this.speedInterval < 0.02 {
                    this.speedInterval = this.speedInterval + 0.001
                }
                this.rotatedSpeed = this.rotatedSpeed + this.speedInterval
            }
            
            let transform = CGAffineTransform.identity.rotated(by: this.rotated)
            DispatchQueue.main.async {
                this.pointBack.setAffineTransform(transform)
            }
        }
        
        codeTimer = timer
        
        addPointAnimation()
    }
    
    func endAnimation(finish: Bool) {
        if finish {
            stop = false
            rotated       = 0
            rotatedSpeed  = 0
            speedInterval = 0
            pointBack.setAffineTransform(CGAffineTransform.identity)
            circle.isHidden = true
            point.isHidden  = true
            codeTimer?.cancel()
            check?.endAnimation()
        } else {
            DispatchQueue.global().async {
                self.stop = true
            }
        }
    }
    
    //MARK: Privater Methods
    private func drawCircle() {
        let width  = frame.size.width
        let height = frame.size.height
        let path = UIBezierPath()
        path.addArc(withCenter: .init(x: width/2, y: height/2), radius: (height - (lineWidth * 2)) / 2, startAngle: 0, endAngle: CGFloat(Double.pi * 2.0), clockwise: false)
        circle.lineWidth   = lineWidth
        circle.strokeColor = color.cgColor
        circle.fillColor   = UIColor.clear.cgColor
        circle.path        = path.cgPath
        addSublayer(circle)
        circle.isHidden = true
    }

    private func drawPoint() {
        let width  = frame.size.width
        let path = UIBezierPath()
        path.addArc(withCenter: .init(x: width/2, y: width/2), radius: (width - (lineWidth * 2)) / 2, startAngle: CGFloat(Double.pi * 1.5), endAngle: CGFloat((Double.pi * 1.5) - 0.1), clockwise: false)
        point.lineCap     = CAShapeLayerLineCap.round
        point.lineWidth   = lineWidth*2
        point.fillColor   = UIColor.clear.cgColor
        point.strokeColor = pointColor.cgColor
        point.path        = path.cgPath
        pointBack.addSublayer(point)
        point.isHidden = true
    }
    
    private func addPointAnimation() {
        let width  = frame.size.width
        let path = CABasicAnimation(keyPath: "path")
        path.beginTime = CACurrentMediaTime() + 1
        path.fromValue = point.path
        let toPath = UIBezierPath()
        toPath.addArc(withCenter: .init(x: width/2, y: width/2), radius:  (width - (lineWidth * 2)) / 2, startAngle: CGFloat(Double.pi * 1.5), endAngle: CGFloat((Double.pi * 1.5) - 0.3), clockwise: false)
        path.toValue = toPath.cgPath
        path.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        path.duration = 2
        path.isRemovedOnCompletion = false
        path.fillMode = CAMediaTimingFillMode.forwards
        point.add(path, forKey: "path")
    }
    
    private func addCheckLayer() {
        check = FastCheckLayer(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), color: pointColor, lineWidth: lineWidth)
        addSublayer(check!)
    }
}
