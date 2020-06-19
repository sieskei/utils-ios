//
//  FastCircleLayer.swift
//
//  Created by Miroslav Yozov on 14.05.18.
//  Copyright © 2018 Net Info.BG EAD. All rights reserved.
//

import UIKit

class FastCircleLayer: CALayer {
    var circle: CAShapeLayer {
        guard let layers = sublayers, layers.count == 3 else {
            fatalError("Missing sublayers!")
        }
        return Utils.castOrFatalError(layers[0])
    }
    
    var pointBack: CALayer {
        guard let layers = sublayers, layers.count == 3 else {
            fatalError("Missing sublayers!")
        }
        return Utils.castOrFatalError(layers[1])
    }
    
    var point: CAShapeLayer {
        guard let layers = pointBack.sublayers, layers.count == 1 else {
            fatalError("Missing sublayers!")
        }
        return Utils.castOrFatalError(layers[0])
    }
    
    var check: FastCheckLayer {
        guard let layers = sublayers, layers.count == 3 else {
            fatalError("Missing sublayers!")
        }
        return Utils.castOrFatalError(layers[2])
    }
    
    //MARK: Initial Methods
    func prepare(frame: CGRect, color: UIColor = .init(rgb: (214, 214, 214)), pointColor: UIColor = .init(rgb: (165, 165, 165)), lineWidth: CGFloat = 1) {
        self.frame = frame
        self.backgroundColor = UIColor.clear.cgColor
        
        self.lineWidth = lineWidth
        
        addSublayer({
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
            }())
        
        addSublayer({
            let layer = CALayer()
            layer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
            layer.backgroundColor = UIColor.clear.cgColor
            
            layer.addSublayer({
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
                }())
            
            return layer
            }())
        
        addSublayer({
            let layer: FastCheckLayer = .init()
            layer.prepare(frame: .init(origin: .zero, size: frame.size), color: pointColor, lineWidth: lineWidth)
            return layer
            }())
    }
    
    //MARK: Public Methods
    func start() {
//        guard !started else {
//            return
//        }
//        
//        started = true
        
        circle.isHidden = false
        point.isHidden  = false
        
        var rotated: CGFloat = 0
        var rotatedSpeed: CGFloat = 0
        var speedInterval: CGFloat = 0
        
        let timer = DispatchSource.makeTimerSource(queue: .global())
        timer.setEventHandler { [weak self] in
            guard let this = self else { return }
            
            rotated -= rotatedSpeed
            
            if this.stop {
                let count = Int(rotated / CGFloat(Double.pi * 2))
                
                if (CGFloat(Double.pi * 2 * Double(count)) - rotated) >= 1.1 {
                    DispatchQueue.main.async {
                        this.pointBack.setAffineTransform(CGAffineTransform.identity.rotated(by: -1.1))
                        this.point.isHidden = true
                        this.check.start()
                    }
                    
                    this.codeTimer = nil
                    return
                }
                
                // make it faster :)
                rotatedSpeed = max(0.175, rotatedSpeed)
            }
            
            if rotatedSpeed < 0.35 {
                speedInterval = min(0.02, speedInterval + 0.001)
                rotatedSpeed += speedInterval
            }
            
            let transform = CGAffineTransform.identity.rotated(by: rotated)
            DispatchQueue.main.async {
                this.pointBack.setAffineTransform(transform)
            }
        }
        
        codeTimer = timer
        
        addPointAnimation()
    }
    
    func stop(finish: Bool) {
        if finish {
//            guard stop else {
//                return
//            }
//
            stop = false
            pointBack.setAffineTransform(.identity)
            circle.isHidden = true
            point.isHidden  = true
            codeTimer = nil
            check.stop()
        } else {
//            guard started else {
//                return
//            }
//            
//            started = false
            stop = true
        }
    }
    
    private func addPointAnimation() {
        let width  = frame.size.width
        let path = CABasicAnimation(keyPath: "path")
        path.beginTime = CACurrentMediaTime() + 1
        path.fromValue = point.path
        let toPath = UIBezierPath()
        toPath.addArc(withCenter: .init(x: width / 2, y: width / 2), radius:  (width - (lineWidth * 2)) / 2, startAngle: CGFloat(Double.pi * 1.5), endAngle: CGFloat((Double.pi * 1.5) - 0.3), clockwise: false)
        path.toValue = toPath.cgPath
        path.timingFunction = .init(name: .easeOut)
        path.duration = 2
        path.isRemovedOnCompletion = false
        path.fillMode = .forwards
        point.add(path, forKey: "path")
    }
}

extension FastCircleLayer: AssociatedObjectCompatible {
    class Props {
        var lineWidth: CGFloat = 1
        
        var started: Bool = false
        var stop: Bool = false
        var codeTimer: DispatchSourceTimer? = nil
    }
    
    private var props: Props {
        return get(for: "props") { .init() }
    }
    
    var lineWidth: CGFloat {
        get { props.lineWidth }
        set { props.lineWidth = newValue }
    }
    
    var started: Bool {
        get { props.started }
        set { props.started = newValue }
    }
    
    var stop: Bool {
        get { props.stop }
        set { props.stop = newValue }
    }
    
    var codeTimer: DispatchSourceTimer? {
        get { return props.codeTimer }
        set {
            props.codeTimer?.cancel()
            props.codeTimer = newValue
            
            if let timer = newValue {
                timer.schedule(deadline: .now(), repeating: .milliseconds(48))
                timer.resume()
            }
        }
    }
}
