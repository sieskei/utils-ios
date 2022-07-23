//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 8.07.22.
//

import UIKit

extension Utils.UI.Layout {
    public struct Constraint { }
}

extension Utils.UI.Layout.Constraint {
    public struct Pair {
        public var first: NSLayoutConstraint
        public var second: NSLayoutConstraint
    }
}

extension Utils.UI.Layout.Constraint {
    public struct Group {
        public var top: NSLayoutConstraint
        public var leading: NSLayoutConstraint
        public var bottom: NSLayoutConstraint
        public var trailing: NSLayoutConstraint

        public var horizontal: [NSLayoutConstraint] {
            [leading, trailing]
        }

        public var vertical: [NSLayoutConstraint] {
            [top, bottom]
        }

        public var all: [NSLayoutConstraint] {
            [top, leading, bottom, trailing]
        }
    }
}

extension Utils.UI.Layout.Constraint {
    public struct Builder {
        typealias Horizontal = (NSLayoutXAxisAnchor, Utils.UI.Layout.Expression<NSLayoutXAxisAnchor, CGFloat>) -> NSLayoutConstraint
        typealias Vertical = (NSLayoutYAxisAnchor, Utils.UI.Layout.Expression<NSLayoutYAxisAnchor, CGFloat>) -> NSLayoutConstraint
        typealias Dimension = (NSLayoutDimension, Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat>) -> NSLayoutConstraint

        public static let equality = Builder(horizontal: ==, vertical: ==, dimension: ==)
        public static let lessThanOrEqual = Builder(leading: <=, top: <=, trailing: >=, bottom: >=, centerX: <=, centerY: <=, dimension: <=)
        public static let greaterThanOrEqual = Builder(leading: >=, top: >=, trailing: <=, bottom: <=, centerX: >=, centerY: >=, dimension: >=)

        var topBuilder: Vertical
        var bottomBuilder: Vertical
        
        var leadingBuilder: Horizontal
        var trailingBuilder: Horizontal
        
        var centerXBuilder: Horizontal
        var centerYBuilder: Vertical
        
        var dimensionBuilder: Dimension

        init(horizontal: @escaping Horizontal, vertical: @escaping Vertical, dimension: @escaping Dimension) {
            topBuilder = vertical
            bottomBuilder = vertical
            
            leadingBuilder = horizontal
            trailingBuilder = horizontal
            
            centerXBuilder = horizontal
            centerYBuilder = vertical
            
            dimensionBuilder = dimension
        }

        init(leading: @escaping Horizontal, top: @escaping Vertical, trailing: @escaping Horizontal, bottom: @escaping Vertical, centerX: @escaping Horizontal, centerY: @escaping Vertical, dimension: @escaping Dimension) {
            topBuilder = top
            bottomBuilder = bottom
            
            leadingBuilder = leading
            trailingBuilder = trailing
            
            centerXBuilder = centerX
            centerYBuilder = centerY
            
            dimensionBuilder = dimension
        }
    }
}

extension Utils.UI.Layout.Constraint {
    class Batch {
        static var instances: [Batch] = []
        
        private (set) var constraints = [NSLayoutConstraint]()

        func add(constraint: NSLayoutConstraint) {
            constraints.append(constraint)
        }

        func activate() {
            NSLayoutConstraint.activate(constraints)
        }
    }
}
