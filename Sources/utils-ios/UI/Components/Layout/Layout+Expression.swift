//
//  Layout+Expression.swift
//  
//
//  Created by Miroslav Yozov on 22.07.22.
//

import UIKit

extension Utils.UI.Layout {
    public struct Expression<T: UtilsUILayoutAnchorType, U: UtilsUILayoutConstantType> {
        public var anchor: T?
        public var constant: U
        public var multiplier: CGFloat
        public var priority: Priority

        internal init(anchor a: T? = nil, constant c: U, multiplier m: CGFloat = 1.0, priority p: Priority = .required) {
            anchor = a
            constant = c
            multiplier = m
            priority = p
        }
    }
}
