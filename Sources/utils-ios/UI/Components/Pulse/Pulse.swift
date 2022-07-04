//
//  Pulse.swift
//  
//
//  Created by Miroslav Yozov on 29.06.22.
//

import UIKit
import RxSwift

extension Utils.UI {
    /**
     Pulse animation.
     */
    public class Pulse {
        public let `type`: `Type`
        
        public init(_ `type`: `Type` = .pointWithBacking) {
            self.`type` = `type`
        }
        
        
        private var status: Status = .collapsed(running: false)
        
        /**
         Triggers the expanding animation.
         - Parameter point: A point to pulse from.
         */
        public func expand(point: CGPoint, in layer: CALayer, withStyle style: Style = .default) {
            switch status {
            case .expaned:
                return
            case .collapsed(let running):
                guard .none != `type`, !running else {
                    return
                }
                
                let layers: Layers = (.init(), .init())
                status = .expaned(layers: layers, running: true)
                
                layer.masksToBounds = !(.centerRadialBeyondBounds == `type` || .radialBeyondBounds == `type`)
                
                layers.backing.addSublayer(layers.pulsing)
                layer.addSublayer(layers.backing)
                
                Utils.UI.disable {
                    let bounds = layer.bounds
                    let width = bounds.width
                    let height = bounds.height
                    let pulseSize = `type` == .center ? min(width, height) : max(width, height)
                    
                    
                    // setup backing layer
                    layers.backing.backgroundColor = UIColor.clear.cgColor
                    layers.backing.zPosition = .zero
                    layers.backing.frame = bounds
                    
                    
                    // setup pulsing layer
                    layers.pulsing.backgroundColor = style.pulsingColor.cgColor
                    layers.pulsing.zPosition = .zero
                    layers.pulsing.frame = .init(origin: .zero, size: .init(width: pulseSize, height: pulseSize))
                    
                    switch `type` {
                    case .center, .centerWithBacking, .centerRadialBeyondBounds:
                        layers.pulsing.position = bounds.center
                    default:
                        layers.pulsing.position = point
                    }

                    layers.pulsing.cornerRadius = pulseSize / 2
                    layers.pulsing.transform = CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 0, y: 0))
                }
                
                let duration: TimeInterval = `type` == .center ? Pulse.maxDuration / 2 : Pulse.maxDuration
                
                switch `type` {
                case .centerWithBacking, .backing, .pointWithBacking:
                    layers.backing.animate(withMaxDuration: duration, animations: .background(color: style.backingColor))
                default:
                    break
                }
                
                switch `type` {
                case .center, .centerWithBacking, .centerRadialBeyondBounds, .radialBeyondBounds, .point, .pointWithBacking:
                    layers.pulsing.animate(withMaxDuration: duration, animations: .scale(1))
                default:
                    break
                }
                
                Utils.UI.async(delay: duration, with: self) {
                    $0.status.completed()
                }
            }
        }
        
        /// Triggers the collapsing animation.
        public func collapse() {
            switch status {
            case .collapsed:
                return
            case .expaned(let layers, let running):
                status = .collapsed(running: true)
                
                let exec: (Pulse) -> Void = { this in
                    switch this.`type` {
                    case .centerWithBacking, .backing, .pointWithBacking:
                        layers.backing.animate(withMaxDuration: Pulse.maxDuration, animations: .background(color: .clear))
                    default:
                        break
                    }
                    
                    switch this.`type` {
                    case .center, .centerWithBacking, .centerRadialBeyondBounds, .radialBeyondBounds, .point, .pointWithBacking:
                        layers.pulsing.animate(withMaxDuration: Pulse.maxDuration, animations: .background(color: .clear))
                    default:
                        break
                    }
                    
                    Utils.UI.async(delay: Pulse.maxDuration) {
                        layers.backing.removeFromSuperlayer()
                        layers.pulsing.removeFromSuperlayer()
                        
                        this.status.completed()
                    }
                }
                
                if running {
                    Utils.UI.async(delay: Pulse.maxDuration, with: self, execution: exec)
                } else {
                    exec(self)
                }
            }
        }
    }
}

extension Utils.UI.Pulse {
    /**
     Maximum duration.
     */
    fileprivate static let maxDuration: TimeInterval = 3
    
    /**
     Typealias for animated layers.
     */
    fileprivate typealias Layers = (backing: CAShapeLayer, pulsing: CAShapeLayer)
    
    /**
     Internal status.
     */
    fileprivate enum Status {
        case collapsed(running: Bool = false)
        case expaned(layers: Layers, running: Bool = false)
        
        var canExpand: Bool {
            switch self {
            case .collapsed:
                return true
            case .expaned:
                return false
            }
        }
        
        mutating func completed() {
            switch self {
            case .expaned(let layers, _):
                self = .expaned(layers: layers, running: false)
            case .collapsed:
                self = .collapsed(running: false)
            }
        }
    }
    
    /**
     Type of pulse animation.
     */
    @objc(`Type`)
    public enum `Type`: Int {
        case none
        case center
        case centerWithBacking
        case centerRadialBeyondBounds
        case radialBeyondBounds
        case backing
        case point
        case pointWithBacking
    }
    
    /**
     Style of pulse animation.
     */
    public struct Style {
        public static var `default`: Style {
            .init(opacity: 0.25, color: .init(red: 158/255, green: 158/255, blue: 158/255, alpha: 1))
        }
        
        let opacity: CGFloat
        let color: UIColor
        
        fileprivate var backingColor: UIColor {
            color.withAlphaComponent(opacity)
        }
        
        fileprivate var pulsingColor: UIColor {
            color.withAlphaComponent(opacity / 2)
        }
    }
}
