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
        private var token: String = Utils.Identifiers.get(length: 6)
        
        public let `type`: `Type`
        
        public init(_ `type`: `Type` =  .pointWithBacking) {
            self.`type` = `type`
        }
        
        /**
         Current status of animation.
         */
        private var progress: Progress = .none
        
        
        /**
         Triggers the expanding animation.
         - Parameter point: A point to pulse from.
         */
        public func expand(point: CGPoint, in layer: CALayer, withStyle style: Style = .default) {
            switch progress {
            case .none:
                progress = .expading(append(at: point, in: layer, withStyle: style) {
                    switch $0.progress {
                    case .none:
                        break
                    case .expading(let layer, _):
                        $0.progress = .expading(layer, finished: true)
                    case .collapsing:
                        $0.remove($1) {
                            switch $0.progress {
                            case .collapsing:
                                $0.progress = .none
                            default:
                                Utils.Log.error("Unexpected progress state.", $0.progress)
                            }
                        }
                    }
                }, finished: false)
            case .expading, .collapsing:
                // Already expanding or collapsing.
                break
            }
        }
        
        /// Triggers the collapsing animation.
        public func collapse() {
            switch progress {
            case .none, .collapsing:
                // Nothing to collapse or already collapsing.
                return
            case .expading(let layer, let finished):
                if finished {
                    remove(layer) {
                        switch $0.progress {
                        case .expading:
                            $0.progress = .none
                        default:
                            Utils.Log.error("Unexpected progress state.", $0.progress)
                        }
                    }
                } else {
                    progress = .collapsing
                }
            }
        }
        
        public func pulse(point: CGPoint, in layer: CALayer, withStyle style: Style = .default) {
            expand(point: point, in: layer, withStyle: style)
            collapse()
        }
        
        public func reset(in layer: CALayer) {
            token = Utils.Identifiers.get(length: 6)
            progress = .none
            layer.clear()
        }
        
        private func append(at point: CGPoint, in layer: CALayer, withStyle style: Style, callback: @escaping (Pulse, CAShapeLayer) -> Void) -> CAShapeLayer {
            let backing: CAShapeLayer = .init()
            let pulsing: CAShapeLayer = .init()
            
            let bounds = layer.bounds
            let width = bounds.width
            let height = bounds.height
            
            // setup backing layer
            backing.backgroundColor = `type`.backing ? style.backingColor.cgColor : UIColor.clear.cgColor
            backing.opacity = .zero
            backing.frame = bounds
            
            // setup pulsing layer if needed
            if `type`.pulsing {
                let size = `type`.center ? min(width, height) : max(width, height)
                
                pulsing.backgroundColor = style.pulsingColor.cgColor
                pulsing.frame = .init(origin: .zero, size: .init(width: size, height: size))
                
                switch `type` {
                case .center, .centerWithBacking:
                    pulsing.position = bounds.center
                default:
                    pulsing.position = point
                }

                pulsing.cornerRadius = size / 2
                pulsing.transform = CATransform3DMakeScale(0.5, 0.5, 1);
                
                backing.addSublayer(pulsing)
            }
            
            // append to super layer
            layer.addSublayer(backing)
            
            if `type`.pulsing {
                pulsing.animate(withMaxDuration: Pulse.maxDuration, animations: .transform(CATransform3DIdentity))
            }
            
            let token = token
            backing.animate(withMaxDuration: Pulse.maxDuration, animations: .opacity(1)) { [weak self] in
                if let this = self, this.token == token {
                    callback(this, backing)
                }
            }
            
            return backing
        }
        
        private func remove(_ layer: CAShapeLayer, callback: @escaping (Pulse) -> Void) {
            let token = token
            layer.animate(withMaxDuration: Pulse.maxDuration, animations: .opacity(.zero)) { [weak self] in
                layer.removeFromSuperlayer()
                if let this = self, this.token == token {
                    callback(this)
                }
            }
        }
        
        deinit {
            switch progress {
            case .expading(let layer, _):
                layer.removeAllAnimations()
                layer.removeFromSuperlayer()
            default:
                break
            }
        }
    }
}

extension Utils.UI.Pulse {
    /**
     Maximum duration.
     */
    fileprivate static let maxDuration: TimeInterval = 0.275
    
    /**
     State of  animations.
     */
    fileprivate enum Progress {
        case none
        case expading(CAShapeLayer, finished: Bool = false)
        case collapsing
    }
    
    
    /**
     Type of pulse animation.
     */
    @objc(`Type`)
    public enum `Type`: Int {
        case none
        
        case center
        case point
        case backing
        
        case centerWithBacking
        case pointWithBacking
        
        var backing: Bool {
            switch self {
            case .backing, .centerWithBacking, .pointWithBacking:
                return true
            default:
                return false
            }
        }
        
        var pulsing: Bool {
            switch self {
            case .center, .point, .centerWithBacking, .pointWithBacking:
                return true
            default:
                return false
            }
        }
        
        var center: Bool {
            switch self {
            case .center, .centerWithBacking:
                return true
            default:
                return false
            }
        }
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

fileprivate extension CALayer {
    func clear() {
        if let layers = sublayers {
            layers.forEach {
                $0.removeAllAnimations()
                $0.removeFromSuperlayer()
            }
        }
    }
}
