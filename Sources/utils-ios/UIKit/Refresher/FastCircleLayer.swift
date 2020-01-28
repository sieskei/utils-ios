//
//  FastCircleLayer.swift
//
//  Created by Miroslav Yozov on 14.05.18.
//  Copyright © 2018 Net Info.BG EAD. All rights reserved.
//

import UIKit

class FastCircleLayer: CALayer {
    let color: UIColor
    let pointColor: UIColor
    let lineWidth: CGFloat
    
    private (set) lazy var circle: CAShapeLayer = {
        let width  = frame.size.width
        let height = frame.size.height
        
        let path = UIBezierPath()
        path.addArc(withCenter: .init(x: width/2, y: height/2), radius: (height - (lineWidth * 2)) / 2, startAngle: 0, endAngle: CGFloat(Double.pi * 2.0), clockwise: false)
        
        let layer = CAShapeLayer()
        
        layer.lineWidth   = lineWidth
        layer.strokeColor = color.cgColor
        layer.fillColor   = UIColor.clear.cgColor
        layer.path        = path.cgPath
        layer.isHidden    = true
        
        return layer
    }()
    
    private (set) lazy var pointBack: CALayer = {
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        layer.backgroundColor = UIColor.clear.cgColor
        return layer
    }()
    
    private (set) lazy var point: CAShapeLayer = {
        let layer = CAShapeLayer()
        
        let width  = frame.size.width
        let path = UIBezierPath()
        path.addArc(withCenter: .init(x: width/2, y: width/2), radius: (width - (lineWidth * 2)) / 2, startAngle: CGFloat(Double.pi * 1.5), endAngle: CGFloat((Double.pi * 1.5) - 0.1), clockwise: false)
        
        layer.lineCap     = CAShapeLayerLineCap.round
        layer.lineWidth   = lineWidth * 2
        layer.fillColor   = UIColor.clear.cgColor
        layer.strokeColor = pointColor.cgColor
        layer.path        = path.cgPath
        
        layer.isHidden = true
        
        return layer
    }()
    
    
    private var rotated: CGFloat = 0
    private var rotatedSpeed: CGFloat = 0
    private var speedInterval: CGFloat = 0
    
    private var stop: Bool = false
    
    private (set) lazy var check: FastCheckLayer = {
        return .init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), color: pointColor, lineWidth: lineWidth)
    }()
    
    private var codeTimer: DispatchSourceTimer? {
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
        
        super.init()
        
        self.frame = frame
        self.backgroundColor = UIColor.clear.cgColor
        
        addSublayer(circle)
        
        pointBack.addSublayer(point)
        addSublayer(pointBack)
        
        addSublayer(check)
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
                        this.check.startAnimation()
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
            pointBack.setAffineTransform(.identity)
            circle.isHidden = true
            point.isHidden  = true
            codeTimer?.cancel()
            check.endAnimation()
        } else {
            DispatchQueue.global().async {
                self.stop = true
            }
        }
    }
    
    private func addPointAnimation() {
        let width  = frame.size.width
        let path = CABasicAnimation(keyPath: "path")
        path.beginTime = CACurrentMediaTime() + 1
        path.fromValue = point.path
        let toPath = UIBezierPath()
        toPath.addArc(withCenter: .init(x: width/2, y: width/2), radius:  (width - (lineWidth * 2)) / 2, startAngle: CGFloat(Double.pi * 1.5), endAngle: CGFloat((Double.pi * 1.5) - 0.3), clockwise: false)
        path.toValue = toPath.cgPath
        path.timingFunction = .init(name: .easeOut)
        path.duration = 2
        path.isRemovedOnCompletion = false
        path.fillMode = .forwards
        point.add(path, forKey: "path")
    }
}
