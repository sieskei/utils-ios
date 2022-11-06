//
//  Height.swift
//  
//
//  Created by Miroslav Yozov on 5.11.22.
//
import UIKit

extension Utils.UI {
    public enum HeightPreset {
        case none
        case tiny
        case xsmall
        case small
        case `default`
        case normal
        case medium
        case large
        case xlarge
        case xxlarge
        case custom(CGFloat)

        public var value: CGFloat {
            switch self {
            case .none:
                return 0
            case .tiny:
                return 20
            case .xsmall:
                return 28
            case .small:
                return 36
            case .`default`:
                return 44
            case .normal:
                return 49
            case .medium:
                return 52
            case .large:
                return 60
            case .xlarge:
                return 68
            case .xxlarge:
                return 104
            case .custom(let v):
                return v
            }
        }
    }
}
