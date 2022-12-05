//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 27.07.22.
//

import UIKit

extension Utils.UI {
    public class Depth {
        static var zero: Depth {
            .init()
        }
        
        /// Offset.
        public var offset: Utils.UI.Offset
      
        /// Opacity.
        public var opacity: Float

        /// Radius.
        public var radius: CGFloat
        
        /// Is zero.
        public var isZero: Bool {
            offset == .zero
        }

        /// A tuple of raw values.
        public var rawValue: (CGSize, Float, CGFloat) {
            (offset.asSize, opacity, radius)
        }
        
        /**
         Initializer that takes in an offset, opacity, and radius.
         - Parameter offset: A UIOffset.
         - Parameter opacity: A Float.
         - Parameter radius: A CGFloat.
         */
        public init(offset: Offset = .zero, opacity: Float = 0, radius: CGFloat = 0) {
            self.offset = offset
            self.opacity = opacity
            self.radius = radius
        }
    }
}

extension Utils.UI.Depth {
    public enum Preset {
        public static func square(_ v: Preset) -> Preset {
            .above(.below(.left(.right(v))))
        }
        
        case none
        case depth1
        case depth2
        case depth3
        case depth4
        case depth5

        indirect case above(Preset)
        indirect case below(Preset)
        indirect case left(Preset)
        indirect case right(Preset)
        
        /// Checks if the preset is the root value (has no direction).
        private var isRoot: Bool {
            switch self {
            case .above:
                return false
            case .below:
                return false
            case .left:
                return false
            case .right:
                return false
            default:
                return true
            }
        }
      
        /// Returns raw depth value without considering direction.
        public var rawValue: Preset {
            switch self {
            case .above(let v):
                return v.rawValue
            case .below(let v):
                return v.rawValue
            case .left(let v):
                return v.rawValue
            case .right(let v):
                return v.rawValue
            default:
                return self
            }
        }
        
        public var value: Utils.UI.Depth {
            switch self {
            case .none:
              return .zero
            case .depth1:
                return .init(offset: .init(horizontal: 0, vertical: 0.5), opacity: 0.3, radius: 0.5)
            case .depth2:
                return .init(offset: .init(horizontal: 0, vertical: 1), opacity: 0.3, radius: 1)
            case .depth3:
                return .init(offset: .init(horizontal: 0, vertical: 2), opacity: 0.3, radius: 2)
            case .depth4:
                return .init(offset: .init(horizontal: 0, vertical: 4), opacity: 0.3, radius: 4)
            case .depth5:
                return .init(offset: .init(horizontal: 0, vertical: 8), opacity: 0.3, radius: 8)
            case .above(let preset):
                let v = preset.value
                if preset.isRoot {
                    v.offset.vertical *= -1
                } else {
                    let value = preset.rawValue.value
                    v.offset.vertical -= value.offset.vertical
                }
                return v
            case .below(let preset):
                let v = preset.value
                if preset.isRoot {
                    return v
                } else {
                    let value = preset.rawValue.value
                    v.offset.vertical += value.offset.vertical
                }
                return v
            case .left(let preset):
                let v = preset.value
                if preset.isRoot {
                    v.offset.horizontal = -v.offset.vertical
                    v.offset.vertical = 0
                } else {
                    let value = preset.rawValue.value
                    v.offset.horizontal -= value.offset.vertical
                }
                return v
            case .right(let preset):
                let v = preset.value
                if preset.isRoot {
                    v.offset.horizontal = v.offset.vertical
                    v.offset.vertical = 0
                } else {
                    let value = preset.rawValue.value
                    v.offset.horizontal += value.offset.vertical
                }
                return v
            }
        }
    }
}
