//
//  Utils.UI.Anchor+Priority.swift
//  
//
//  Created by Miroslav Yozov on 7.07.22.
//

import UIKit

extension Utils.UI.Anchor {
    public enum Priority: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, Equatable {
        case required
        case high
        case low
        case fittingSize
        case custom(UILayoutPriority)
        
        public var value: UILayoutPriority {
            switch self {
            case .required:
                return .required
            case .high:
                return .defaultHigh
            case .low:
                return .defaultLow
            case .fittingSize:
                return .fittingSizeLevel
            case .custom(let priority):
                return priority
            }
        }
        
        public init(floatLiteral value: Float) {
            self = .custom(UILayoutPriority(value))
        }

        public init(integerLiteral value: Int) {
            self.init(value)
        }

        public init(_ value: Int) {
            self = .custom(UILayoutPriority(Float(value)))
        }

        public init<T: BinaryFloatingPoint>(_ value: T) {
            self = .custom(UILayoutPriority(Float(value)))
        }
    }
}

public func == (lhs: Utils.UI.Anchor.Priority, rhs: Utils.UI.Anchor.Priority) -> Bool {
    lhs.value == rhs.value
}

public func + <T: BinaryFloatingPoint>(lhs: Utils.UI.Anchor.Priority, rhs: T) -> Utils.UI.Anchor.Priority {
    .custom(UILayoutPriority(rawValue: lhs.value.rawValue + Float(rhs)))
}

public func + <T: BinaryFloatingPoint>(lhs: T, rhs: Utils.UI.Anchor.Priority) -> Utils.UI.Anchor.Priority {
    .custom(UILayoutPriority(rawValue: Float(lhs) + rhs.value.rawValue))
}

public func - <T: BinaryFloatingPoint>(lhs: Utils.UI.Anchor.Priority, rhs: T) -> Utils.UI.Anchor.Priority {
    .custom(UILayoutPriority(rawValue: lhs.value.rawValue - Float(rhs)))
}

public func - <T: BinaryFloatingPoint>(lhs: T, rhs: Utils.UI.Anchor.Priority) -> Utils.UI.Anchor.Priority {
    .custom(UILayoutPriority(rawValue: Float(lhs) - rhs.value.rawValue))
}
