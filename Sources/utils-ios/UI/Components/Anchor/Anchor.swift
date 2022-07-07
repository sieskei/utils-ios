//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 7.07.22.
//

import UIKit

// MARK: - namespaces
extension Utils.UI {
    public struct Anchor { }
}

extension Utils.UI.Anchor {
    public struct Constraints { }
}

extension Utils.UI.Anchor {
    public struct Anchors { }
}

extension Utils.UI.Anchor {
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


extension Utils.UI.Anchor.Anchors {
    public struct Pair<T: UtilsUILayoutAnchorType, U: UtilsUILayoutAnchorType>: UtilsUILayoutAnchorType {
        public var first: T
        public var second: U

        internal init(first f: T, second s: U) {
            first = f
            second = s
        }
    }
}

extension Utils.UI.Anchor.Constraints {
    public struct Pair {
        public var first: NSLayoutConstraint
        public var second: NSLayoutConstraint
    }
}


extension Utils.UI.Anchor.Constraints {
    public struct Groupß {
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



public extension Utils.UI.Anchor.Anchors {
    struct Edges: UtilsUILayoutAnchorType {
        public var horizontalAnchors: Utils.UI.Anchor.Anchors.Pair<NSLayoutXAxisAnchor, NSLayoutXAxisAnchor>
        public var verticalAnchors: Utils.UI.Anchor.Anchors.Pair<NSLayoutYAxisAnchor, NSLayoutYAxisAnchor>
    }
}


extension Utils.UI.Anchor.Constraints {
    internal struct Builder {
        typealias Horizontal = (NSLayoutXAxisAnchor, Expression<NSLayoutXAxisAnchor, CGFloat>) -> NSLayoutConstraint
        typealias Vertical = (NSLayoutYAxisAnchor, Expression<NSLayoutYAxisAnchor, CGFloat>) -> NSLayoutConstraint
        typealias Dimension = (NSLayoutDimension, Expression<NSLayoutDimension, CGFloat>) -> NSLayoutConstraint

        static let equality = Builder(horizontal: ==, vertical: ==, dimension: ==)
        static let lessThanOrEqual = Builder(leading: <=, top: <=, trailing: >=, bottom: >=, centerX: <=, centerY: <=, dimension: <=)
        static let greaterThanOrEqual = Builder(leading: >=, top: >=, trailing: <=, bottom: <=, centerX: >=, centerY: >=, dimension: >=)

        var topBuilder: Vertical
        var leadingBuilder: Horizontal
        var bottomBuilder: Vertical
        var trailingBuilder: Horizontal
        var centerYBuilder: Vertical
        var centerXBuilder: Horizontal
        var dimensionBuilder: Dimension

        init(horizontal: @escaping Horizontal, vertical: @escaping Vertical, dimension: @escaping Dimension) {
            topBuilder = vertical
            leadingBuilder = horizontal
            bottomBuilder = vertical
            trailingBuilder = horizontal
            centerYBuilder = vertical
            centerXBuilder = horizontal
            dimensionBuilder = dimension
        }

        init(leading: @escaping Horizontal, top: @escaping Vertical, trailing: @escaping Horizontal, bottom: @escaping Vertical, centerX: @escaping Horizontal, centerY: @escaping Vertical, dimension: @escaping Dimension) {
            leadingBuilder = leading
            topBuilder = top
            trailingBuilder = trailing
            bottomBuilder = bottom
            centerYBuilder = centerY
            centerXBuilder = centerX
            dimensionBuilder = dimension
        }
    }
}


// MARK: - Equality Constraints

infix operator /==/: ComparisonPrecedence

@discardableResult
public func == <T: BinaryFloatingPoint>(lhs: NSLayoutDimension,
                                        rhs: T) -> NSLayoutConstraint {
    lhs /==/ rhs
}

@discardableResult
public func /==/ <T: BinaryFloatingPoint>(lhs: NSLayoutDimension,
                                          rhs: T) -> NSLayoutConstraint {
    finalize(constraint: lhs.constraint(equalToConstant: CGFloat(rhs)))
}

@discardableResult
public func == (lhs: NSLayoutXAxisAnchor, rhs: NSLayoutXAxisAnchor) -> NSLayoutConstraint {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: NSLayoutXAxisAnchor, rhs: NSLayoutXAxisAnchor) -> NSLayoutConstraint {
    finalize(constraint: lhs.constraint(equalTo: rhs))
}

@discardableResult
public func == (lhs: NSLayoutYAxisAnchor, rhs: NSLayoutYAxisAnchor) -> NSLayoutConstraint {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: NSLayoutYAxisAnchor,
                  rhs: NSLayoutYAxisAnchor) -> NSLayoutConstraint {
    finalize(constraint: lhs.constraint(equalTo: rhs))
}

@discardableResult
public func == (lhs: NSLayoutDimension,
                rhs: NSLayoutDimension) -> NSLayoutConstraint {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: NSLayoutDimension,
                  rhs: NSLayoutDimension) -> NSLayoutConstraint {
    return finalize(constraint: lhs.constraint(equalTo: rhs))
}

@discardableResult
public func == (lhs: NSLayoutXAxisAnchor,
                rhs: Utils.UI.Anchor.Expression<NSLayoutXAxisAnchor, CGFloat>) -> NSLayoutConstraint {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: NSLayoutXAxisAnchor,
                  rhs: Utils.UI.Anchor.Expression<NSLayoutXAxisAnchor, CGFloat>) -> NSLayoutConstraint {
    finalize(constraint: lhs.constraint(equalTo: rhs.anchor!, multiplier: rhs.multiplier, constant: rhs.constant), withPriority: rhs.priority)
}

@discardableResult
public func == (lhs: NSLayoutYAxisAnchor, rhs: Utils.UI.Anchor.Expression<NSLayoutYAxisAnchor, CGFloat>) -> NSLayoutConstraint {
    return lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: NSLayoutYAxisAnchor, rhs: Utils.UI.Anchor.Expression<NSLayoutYAxisAnchor, CGFloat>) -> NSLayoutConstraint {
    return finalize(constraint: lhs.constraint(equalTo: rhs.anchor!, multiplier: rhs.multiplier, constant: rhs.constant), withPriority: rhs.priority)
}

@discardableResult
public func == (lhs: NSLayoutDimension,
                rhs: Utils.UI.Anchor.Expression<NSLayoutDimension, CGFloat>) -> NSLayoutConstraint {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: NSLayoutDimension,
                  rhs: Utils.UI.Anchor.Expression<NSLayoutDimension, CGFloat>) -> NSLayoutConstraint {
    if let anchor = rhs.anchor {
        return finalize(constraint: lhs.constraint(equalTo: anchor, multiplier: rhs.multiplier, constant: rhs.constant), withPriority: rhs.priority)
    }
    else {
        return finalize(constraint: lhs.constraint(equalToConstant: rhs.constant), withPriority: rhs.priority)
    }
}

@discardableResult
public func == (lhs: Utils.UI.Anchor.Edges,
                rhs: Utils.UI.Anchor.Edges) -> Utils.UI.Anchor.ConstraintGroup {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: Utils.UI.Anchor.Edges,
                  rhs: Utils.UI.Anchor.Edges) -> Utils.UI.Anchor.ConstraintGroup {
    lhs.finalize(constraintsEqualToEdges: rhs)
}

@discardableResult
public func == (lhs: Utils.UI.Anchor.Edges,
                rhs: Utils.UI.Anchor.Expression<Utils.UI.Anchor.Edges, CGFloat>) -> Utils.UI.Anchor.ConstraintGroup {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: Utils.UI.Anchor.Edges,
                  rhs: Utils.UI.Anchor.Expression<Utils.UI.Anchor.Edges, CGFloat>) -> Utils.UI.Anchor.ConstraintGroup {
    lhs.finalize(constraintsEqualToEdges: rhs.anchor, constant: rhs.constant, priority: rhs.priority)
}

@discardableResult
public func == (lhs: Utils.UI.Anchor.Edges,
                rhs: Utils.UI.Anchor.Expression<Utils.UI.Anchor.Edges, UIEdgeInsets>) -> Utils.UI.Anchor.ConstraintGroup {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: Utils.UI.Anchor.Edges, rhs: Utils.UI.Anchor.Expression<Utils.UI.Anchor.Edges, UIEdgeInsets>) -> Utils.UI.Anchor.ConstraintGroup {
    lhs.finalize(constraintsEqualToEdges: rhs.anchor, insets: rhs.constant, priority: rhs.priority)
}

@discardableResult
public func == <T, U>(lhs: Utils.UI.Anchor.AnchorPair<T, U>, rhs: AnchorPair<T, U>) -> Utils.UI.Anchor.ConstraintPair {
    lhs /==/ rhs
}

@discardableResult
public func /==/ <T, U>(lhs: Utils.UI.Anchor.AnchorPair<T, U>, rhs: AnchorPair<T, U>) -> Utils.UI.Anchor.ConstraintPair {
    return lhs.finalize(constraintsEqualToEdges: rhs)
}

@discardableResult
public func == <T, U>(lhs: Utils.UI.Anchor.AnchorPair<T, U>,
                      rhs: Utils.UI.Anchor.Expression<Utils.UI.Anchor.AnchorPair<T, U>, CGFloat>) -> Utils.UI.Anchor.ConstraintPair {
    lhs /==/ rhs
}

@discardableResult
public func /==/ <T, U>(lhs: Utils.UI.Anchor.AnchorPair<T, U>,
                        rhs: Utils.UI.Anchor.Expression<Utils.UI.Anchor.AnchorPair<T, U>, CGFloat>) -> Utils.UI.Anchor.ConstraintPair {
    lhs.finalize(constraintsEqualToEdges: rhs.anchor, constant: rhs.constant, priority: rhs.priority)
}

@discardableResult
public func == (lhs: Utils.UI.Anchor.AnchorPair<NSLayoutDimension, NSLayoutDimension>,
                rhs: CGSize) -> Utils.UI.Anchor.ConstraintPair {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: Utils.UI.Anchor.AnchorPair<NSLayoutDimension, NSLayoutDimension>,
                  rhs: CGSize) -> Utils.UI.Anchor.ConstraintPair {
    lhs.finalize(constraintsEqualToConstant: rhs)
}

@discardableResult
public func == (lhs: Utils.UI.Anchor.AnchorPair<NSLayoutDimension, NSLayoutDimension>,
                rhs: Utils.UI.Anchor.Expression<Utils.UI.Anchor.AnchorPair<NSLayoutDimension, NSLayoutDimension>, CGSize>) -> Utils.UI.Anchor.ConstraintPair {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: Utils.UI.Anchor.AnchorPair<NSLayoutDimension, NSLayoutDimension>,
                  rhs: Utils.UI.Anchor.Expression<Utils.UI.Anchor.AnchorPair<NSLayoutDimension, NSLayoutDimension>, CGSize>) -> Utils.UI.Anchor.ConstraintPair {
    lhs.finalize(constraintsEqualToConstant: rhs.constant, priority: rhs.priority)
}
