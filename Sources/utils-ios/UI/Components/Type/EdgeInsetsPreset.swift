//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 20.07.22.
//

import Foundation

import UIKit

extension Utils.UI {
    @objc(EdgeInsetsPreset)
    public enum EdgeInsetsPreset: Int {
        case none

        // square
        case square1
        case square2
        case square3
        case square4
        case square5
        case square6
        case square7
        case square8
        case square9
        case square10
        case square11
        case square12
        case square13
        case square14
        case square15

        // rectangle
        case wideRectangle1
        case wideRectangle2
        case wideRectangle3
        case wideRectangle4
        case wideRectangle5
        case wideRectangle6
        case wideRectangle7
        case wideRectangle8
        case wideRectangle9

        // flipped rectangle
        case tallRectangle1
        case tallRectangle2
        case tallRectangle3
        case tallRectangle4
        case tallRectangle5
        case tallRectangle6
        case tallRectangle7
        case tallRectangle8
        case tallRectangle9

        /// horizontally
        case horizontally1
        case horizontally2
        case horizontally3
        case horizontally4
        case horizontally5

        /// vertically
        case vertically1
        case vertically2
        case vertically3
        case vertically4
        case vertically5
        
        /// Converts the UIEdgeInsetsPreset to a Inset value.
        var value: UIEdgeInsets {
            switch self {
            case .none:
                return .zero
            // square
            case .square1:
                return .init(top: 4, left: 4, bottom: 4, right: 4)
            case .square2:
                return .init(top: 8, left: 8, bottom: 8, right: 8)
            case .square3:
                return .init(top: 16, left: 16, bottom: 16, right: 16)
            case .square4:
                return .init(top: 20, left: 20, bottom: 20, right: 20)
            case .square5:
                return .init(top: 24, left: 24, bottom: 24, right: 24)
            case .square6:
                return .init(top: 28, left: 28, bottom: 28, right: 28)
            case .square7:
                return .init(top: 32, left: 32, bottom: 32, right: 32)
            case .square8:
                return .init(top: 36, left: 36, bottom: 36, right: 36)
            case .square9:
                return .init(top: 40, left: 40, bottom: 40, right: 40)
            case .square10:
                return .init(top: 44, left: 44, bottom: 44, right: 44)
            case .square11:
                return .init(top: 48, left: 48, bottom: 48, right: 48)
            case .square12:
                return .init(top: 52, left: 52, bottom: 52, right: 52)
            case .square13:
                return .init(top: 56, left: 56, bottom: 56, right: 56)
            case .square14:
                return .init(top: 60, left: 60, bottom: 60, right: 60)
            case .square15:
                return .init(top: 64, left: 64, bottom: 64, right: 64)

            // rectangle
            case .wideRectangle1:
                return .init(top: 2, left: 4, bottom: 2, right: 4)
            case .wideRectangle2:
                return .init(top: 4, left: 8, bottom: 4, right: 8)
            case .wideRectangle3:
                return .init(top: 8, left: 16, bottom: 8, right: 16)
            case .wideRectangle4:
                return .init(top: 12, left: 24, bottom: 12, right: 24)
            case .wideRectangle5:
                return .init(top: 16, left: 32, bottom: 16, right: 32)
            case .wideRectangle6:
                return .init(top: 20, left: 40, bottom: 20, right: 40)
            case .wideRectangle7:
                return .init(top: 24, left: 48, bottom: 24, right: 48)
            case .wideRectangle8:
                return .init(top: 28, left: 56, bottom: 28, right: 56)
            case .wideRectangle9:
                return .init(top: 32, left: 64, bottom: 32, right: 64)

            // flipped rectangle
            case .tallRectangle1:
                return .init(top: 4, left: 2, bottom: 4, right: 2)
            case .tallRectangle2:
                return .init(top: 8, left: 4, bottom: 8, right: 4)
            case .tallRectangle3:
                return .init(top: 16, left: 8, bottom: 16, right: 8)
            case .tallRectangle4:
                return .init(top: 24, left: 12, bottom: 24, right: 12)
            case .tallRectangle5:
                return .init(top: 32, left: 16, bottom: 32, right: 16)
            case .tallRectangle6:
                return .init(top: 40, left: 20, bottom: 40, right: 20)
            case .tallRectangle7:
                return .init(top: 48, left: 24, bottom: 48, right: 24)
            case .tallRectangle8:
                return .init(top: 56, left: 28, bottom: 56, right: 28)
            case .tallRectangle9:
                return .init(top: 64, left: 32, bottom: 64, right: 32)

            /// horizontally
            case .horizontally1:
                return .init(top: 0, left: 2, bottom: 0, right: 2)
            case .horizontally2:
                return .init(top: 0, left: 4, bottom: 0, right: 4)
            case .horizontally3:
                return .init(top: 0, left: 8, bottom: 0, right: 8)
            case .horizontally4:
                return .init(top: 0, left: 16, bottom: 0, right: 16)
            case .horizontally5:
                return .init(top: 0, left: 24, bottom: 0, right: 24)

            /// vertically
            case .vertically1:
                return .init(top: 2, left: 0, bottom: 2, right: 0)
            case .vertically2:
                return .init(top: 4, left: 0, bottom: 4, right: 0)
            case .vertically3:
                return .init(top: 8, left: 0, bottom: 8, right: 0)
            case .vertically4:
                return .init(top: 16, left: 0, bottom: 16, right: 0)
            case .vertically5:
                return .init(top: 24, left: 0, bottom: 24, right: 0)
            }
        }
    }
}


