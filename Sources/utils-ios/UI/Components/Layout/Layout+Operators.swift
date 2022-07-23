//
//  Layout+Operators.swift
//  
//
//  Created by Miroslav Yozov on 22.07.22.
//

import UIKit

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
    Utils.UI.Layout.finalize(constraint: lhs.constraint(equalToConstant: CGFloat(rhs)))
}

@discardableResult
public func == (lhs: NSLayoutXAxisAnchor, rhs: NSLayoutXAxisAnchor) -> NSLayoutConstraint {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: NSLayoutXAxisAnchor, rhs: NSLayoutXAxisAnchor) -> NSLayoutConstraint {
    Utils.UI.Layout.finalize(constraint: lhs.constraint(equalTo: rhs))
}

@discardableResult
public func == (lhs: NSLayoutYAxisAnchor, rhs: NSLayoutYAxisAnchor) -> NSLayoutConstraint {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: NSLayoutYAxisAnchor,
                  rhs: NSLayoutYAxisAnchor) -> NSLayoutConstraint {
    Utils.UI.Layout.finalize(constraint: lhs.constraint(equalTo: rhs))
}

@discardableResult
public func == (lhs: NSLayoutDimension,
                rhs: NSLayoutDimension) -> NSLayoutConstraint {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: NSLayoutDimension,
                  rhs: NSLayoutDimension) -> NSLayoutConstraint {
    Utils.UI.Layout.finalize(constraint: lhs.constraint(equalTo: rhs))
}

@discardableResult
public func == (lhs: NSLayoutXAxisAnchor,
                rhs: Utils.UI.Layout.Expression<NSLayoutXAxisAnchor, CGFloat>) -> NSLayoutConstraint {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: NSLayoutXAxisAnchor,
                  rhs: Utils.UI.Layout.Expression<NSLayoutXAxisAnchor, CGFloat>) -> NSLayoutConstraint {
    Utils.UI.Layout.finalize(constraint: lhs.constraint(equalTo: rhs.anchor!, multiplier: rhs.multiplier, constant: rhs.constant), withPriority: rhs.priority)
}

@discardableResult
public func == (lhs: NSLayoutYAxisAnchor, rhs: Utils.UI.Layout.Expression<NSLayoutYAxisAnchor, CGFloat>) -> NSLayoutConstraint {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: NSLayoutYAxisAnchor, rhs: Utils.UI.Layout.Expression<NSLayoutYAxisAnchor, CGFloat>) -> NSLayoutConstraint {
    Utils.UI.Layout.finalize(constraint: lhs.constraint(equalTo: rhs.anchor!, multiplier: rhs.multiplier, constant: rhs.constant), withPriority: rhs.priority)
}

@discardableResult
public func == (lhs: NSLayoutDimension,
                rhs: Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat>) -> NSLayoutConstraint {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: NSLayoutDimension,
                  rhs: Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat>) -> NSLayoutConstraint {
    if let anchor = rhs.anchor {
        return Utils.UI.Layout.finalize(constraint: lhs.constraint(equalTo: anchor, multiplier: rhs.multiplier, constant: rhs.constant), withPriority: rhs.priority)
    }
    else {
        return Utils.UI.Layout.finalize(constraint: lhs.constraint(equalToConstant: rhs.constant), withPriority: rhs.priority)
    }
}

@discardableResult
public func == (lhs: Utils.UI.Layout.Anchor.Edges,
                rhs: Utils.UI.Layout.Anchor.Edges) -> Utils.UI.Layout.Constraint.Group {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: Utils.UI.Layout.Anchor.Edges,
                  rhs: Utils.UI.Layout.Anchor.Edges) -> Utils.UI.Layout.Constraint.Group {
    lhs.finalize(constraintsEqualToEdges: rhs)
}

@discardableResult
public func == (lhs: Utils.UI.Layout.Anchor.Edges,
                rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Edges, CGFloat>) -> Utils.UI.Layout.Constraint.Group {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: Utils.UI.Layout.Anchor.Edges,
                  rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Edges, CGFloat>) -> Utils.UI.Layout.Constraint.Group {
    lhs.finalize(constraintsEqualToEdges: rhs.anchor, constant: rhs.constant, priority: rhs.priority)
}

@discardableResult
public func == (lhs: Utils.UI.Layout.Anchor.Edges,
                rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Edges, UIEdgeInsets>) -> Utils.UI.Layout.Constraint.Group {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: Utils.UI.Layout.Anchor.Edges, rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Edges, UIEdgeInsets>) -> Utils.UI.Layout.Constraint.Group {
    lhs.finalize(constraintsEqualToEdges: rhs.anchor, insets: rhs.constant, priority: rhs.priority)
}

@discardableResult
public func == <T, U>(lhs: Utils.UI.Layout.Anchor.Pair<T, U>, rhs: Utils.UI.Layout.Anchor.Pair<T, U>) -> Utils.UI.Layout.Constraint.Pair {
    lhs /==/ rhs
}

@discardableResult
public func /==/ <T, U>(lhs: Utils.UI.Layout.Anchor.Pair<T, U>, rhs: Utils.UI.Layout.Anchor.Pair<T, U>) -> Utils.UI.Layout.Constraint.Pair {
    lhs.finalize(constraintsEqualToEdges: rhs)
}

@discardableResult
public func == <T, U>(lhs: Utils.UI.Layout.Anchor.Pair<T, U>,
                      rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Pair<T, U>, CGFloat>) -> Utils.UI.Layout.Constraint.Pair {
    lhs /==/ rhs
}

@discardableResult
public func /==/ <T, U>(lhs: Utils.UI.Layout.Anchor.Pair<T, U>,
                        rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Pair<T, U>, CGFloat>) -> Utils.UI.Layout.Constraint.Pair {
    lhs.finalize(constraintsEqualToEdges: rhs.anchor, constant: rhs.constant, priority: rhs.priority)
}

@discardableResult
public func == (lhs: Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>,
                rhs: CGSize) -> Utils.UI.Layout.Constraint.Pair {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>,
                  rhs: CGSize) -> Utils.UI.Layout.Constraint.Pair {
    lhs.finalize(constraintsEqualToConstant: rhs)
}

@discardableResult
public func == (lhs: Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>,
                rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>, CGSize>) -> Utils.UI.Layout.Constraint.Pair {
    lhs /==/ rhs
}

@discardableResult
public func /==/ (lhs: Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>,
                  rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>, CGSize>) -> Utils.UI.Layout.Constraint.Pair {
    lhs.finalize(constraintsEqualToConstant: rhs.constant, priority: rhs.priority)
}


// MARK: Less Than or Equal To

infix operator /<=/: ComparisonPrecedence

@discardableResult
public func <= <T: BinaryFloatingPoint>(lhs: NSLayoutDimension,
                                        rhs: T) -> NSLayoutConstraint {
    lhs /<=/ rhs
}

@discardableResult
public func /<=/ <T: BinaryFloatingPoint>(lhs: NSLayoutDimension,
                                          rhs: T) -> NSLayoutConstraint {
    Utils.UI.Layout.finalize(constraint: lhs.constraint(lessThanOrEqualToConstant: CGFloat(rhs)))
}

@discardableResult
public func <= (lhs: NSLayoutXAxisAnchor,
                rhs: NSLayoutXAxisAnchor) -> NSLayoutConstraint {
    lhs /<=/ rhs
}

@discardableResult
public func /<=/ (lhs: NSLayoutXAxisAnchor,
                  rhs: NSLayoutXAxisAnchor) -> NSLayoutConstraint {
    Utils.UI.Layout.finalize(constraint: lhs.constraint(lessThanOrEqualTo: rhs))
}

@discardableResult
public func <= (lhs: NSLayoutYAxisAnchor,
                rhs: NSLayoutYAxisAnchor) -> NSLayoutConstraint {
    lhs /<=/ rhs
}

@discardableResult
public func /<=/ (lhs: NSLayoutYAxisAnchor,
                  rhs: NSLayoutYAxisAnchor) -> NSLayoutConstraint {
    Utils.UI.Layout.finalize(constraint: lhs.constraint(lessThanOrEqualTo: rhs))
}

@discardableResult
public func <= (lhs: NSLayoutDimension,
                rhs: NSLayoutDimension) -> NSLayoutConstraint {
    lhs /<=/ rhs
}

@discardableResult
public func /<=/ (lhs: NSLayoutDimension,
                  rhs: NSLayoutDimension) -> NSLayoutConstraint {
    Utils.UI.Layout.finalize(constraint: lhs.constraint(lessThanOrEqualTo: rhs))
}

@discardableResult
public func <= (lhs: NSLayoutXAxisAnchor,
                rhs: Utils.UI.Layout.Expression<NSLayoutXAxisAnchor, CGFloat>) -> NSLayoutConstraint {
    lhs /<=/ rhs
}

@discardableResult
public func /<=/ (lhs: NSLayoutXAxisAnchor,
                  rhs: Utils.UI.Layout.Expression<NSLayoutXAxisAnchor, CGFloat>) -> NSLayoutConstraint {
    Utils.UI.Layout.finalize(constraint: lhs.constraint(lessThanOrEqualTo: rhs.anchor!, multiplier: rhs.multiplier, constant: rhs.constant), withPriority: rhs.priority)
}

@discardableResult
public func <= (lhs: NSLayoutYAxisAnchor,
                rhs: Utils.UI.Layout.Expression<NSLayoutYAxisAnchor, CGFloat>) -> NSLayoutConstraint {
    lhs /<=/ rhs
}

@discardableResult
public func /<=/ (lhs: NSLayoutYAxisAnchor,
                  rhs: Utils.UI.Layout.Expression<NSLayoutYAxisAnchor, CGFloat>) -> NSLayoutConstraint {
    Utils.UI.Layout.finalize(constraint: lhs.constraint(lessThanOrEqualTo: rhs.anchor!, multiplier: rhs.multiplier, constant: rhs.constant), withPriority: rhs.priority)
}

@discardableResult
public func <= (lhs: NSLayoutDimension,
                rhs: Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat>) -> NSLayoutConstraint {
    lhs /<=/ rhs
}

@discardableResult
public func /<=/ (lhs: NSLayoutDimension,
                  rhs: Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat>) -> NSLayoutConstraint {
    if let anchor = rhs.anchor {
        return Utils.UI.Layout.finalize(constraint: lhs.constraint(lessThanOrEqualTo: anchor, multiplier: rhs.multiplier, constant: rhs.constant), withPriority: rhs.priority)
    }
    else {
        return Utils.UI.Layout.finalize(constraint: lhs.constraint(lessThanOrEqualToConstant: rhs.constant), withPriority: rhs.priority)
    }
}

@discardableResult
public func <= (lhs: Utils.UI.Layout.Anchor.Edges,
                rhs: Utils.UI.Layout.Anchor.Edges) -> Utils.UI.Layout.Constraint.Group {
    lhs /<=/ rhs
}

@discardableResult
public func /<=/ (lhs: Utils.UI.Layout.Anchor.Edges,
                  rhs: Utils.UI.Layout.Anchor.Edges) -> Utils.UI.Layout.Constraint.Group {
    lhs.finalize(constraintsLessThanOrEqualToEdges: rhs)
}

@discardableResult
public func <= (lhs: Utils.UI.Layout.Anchor.Edges,
                rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Edges, CGFloat>) -> Utils.UI.Layout.Constraint.Group {
    lhs /<=/ rhs
}

@discardableResult
public func /<=/ (lhs: Utils.UI.Layout.Anchor.Edges,
                  rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Edges, CGFloat>) -> Utils.UI.Layout.Constraint.Group {
    lhs.finalize(constraintsLessThanOrEqualToEdges: rhs.anchor, constant: rhs.constant, priority: rhs.priority)
}

@discardableResult
public func <= (lhs: Utils.UI.Layout.Anchor.Edges,
                rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Edges, UIEdgeInsets>) -> Utils.UI.Layout.Constraint.Group {
    lhs /<=/ rhs
}

@discardableResult
public func /<=/ (lhs: Utils.UI.Layout.Anchor.Edges,
                  rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Edges, UIEdgeInsets>) -> Utils.UI.Layout.Constraint.Group {
    lhs.finalize(constraintsLessThanOrEqualToEdges: rhs.anchor, insets: rhs.constant, priority: rhs.priority)
}

@discardableResult
public func <= <T, U>(lhs: Utils.UI.Layout.Anchor.Pair<T, U>, rhs: Utils.UI.Layout.Anchor.Pair<T, U>) -> Utils.UI.Layout.Constraint.Pair {
    lhs /<=/ rhs
}

@discardableResult
public func /<=/ <T, U>(lhs: Utils.UI.Layout.Anchor.Pair<T, U>, rhs: Utils.UI.Layout.Anchor.Pair<T, U>) -> Utils.UI.Layout.Constraint.Pair {
    lhs.finalize(constraintsLessThanOrEqualToEdges: rhs)
}

@discardableResult
public func <= <T, U>(lhs: Utils.UI.Layout.Anchor.Pair<T, U>,
                      rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Pair<T, U>, CGFloat>) -> Utils.UI.Layout.Constraint.Pair {
    lhs /<=/ rhs
}

@discardableResult
public func /<=/ <T, U>(lhs: Utils.UI.Layout.Anchor.Pair<T, U>,
                        rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Pair<T, U>, CGFloat>) -> Utils.UI.Layout.Constraint.Pair {
    lhs.finalize(constraintsLessThanOrEqualToEdges: rhs.anchor, constant: rhs.constant, priority: rhs.priority)
}

@discardableResult
public func <= (lhs: Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>,
                rhs: CGSize) -> Utils.UI.Layout.Constraint.Pair {
    lhs /<=/ rhs
}

@discardableResult
public func /<=/ (lhs: Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>,
                  rhs: CGSize) -> Utils.UI.Layout.Constraint.Pair {
    lhs.finalize(constraintsLessThanOrEqualToConstant: rhs)
}

@discardableResult
public func <= (lhs: Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>,
                rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>, CGSize>) -> Utils.UI.Layout.Constraint.Pair {
    lhs /<=/ rhs
}

@discardableResult
public func /<=/ (lhs: Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>,
                  rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>, CGSize>) -> Utils.UI.Layout.Constraint.Pair {
    lhs.finalize(constraintsLessThanOrEqualToConstant: rhs.constant, priority: rhs.priority)
}


// MARK: Greater Than or Equal To

infix operator />=/: ComparisonPrecedence

@discardableResult
public func >= <T: BinaryFloatingPoint>(lhs: NSLayoutDimension,
                                        rhs: T) -> NSLayoutConstraint {
    lhs />=/ rhs
}

@discardableResult
public func />=/ <T: BinaryFloatingPoint>(lhs: NSLayoutDimension,
                                          rhs: T) -> NSLayoutConstraint {
    Utils.UI.Layout.finalize(constraint: lhs.constraint(greaterThanOrEqualToConstant: CGFloat(rhs)))
}

@discardableResult
public func >= (lhs: NSLayoutXAxisAnchor,
                rhs: NSLayoutXAxisAnchor) -> NSLayoutConstraint {
    lhs />=/ rhs
}

@discardableResult
public func />=/ (lhs: NSLayoutXAxisAnchor,
                  rhs: NSLayoutXAxisAnchor) -> NSLayoutConstraint {
    Utils.UI.Layout.finalize(constraint: lhs.constraint(greaterThanOrEqualTo: rhs))
}

@discardableResult
public func >= (lhs: NSLayoutYAxisAnchor,
                rhs: NSLayoutYAxisAnchor) -> NSLayoutConstraint {
    lhs />=/ rhs
}

@discardableResult
public func />=/ (lhs: NSLayoutYAxisAnchor,
                  rhs: NSLayoutYAxisAnchor) -> NSLayoutConstraint {
    Utils.UI.Layout.finalize(constraint: lhs.constraint(greaterThanOrEqualTo: rhs))
}

@discardableResult
public func >= (lhs: NSLayoutDimension,
                rhs: NSLayoutDimension) -> NSLayoutConstraint {
    lhs />=/ rhs
}

@discardableResult
public func />=/ (lhs: NSLayoutDimension,
                  rhs: NSLayoutDimension) -> NSLayoutConstraint {
    Utils.UI.Layout.finalize(constraint: lhs.constraint(greaterThanOrEqualTo: rhs))
}

@discardableResult
public func >= (lhs: NSLayoutXAxisAnchor,
                rhs: Utils.UI.Layout.Expression<NSLayoutXAxisAnchor, CGFloat>) -> NSLayoutConstraint {
    lhs />=/ rhs
}

@discardableResult
public func />=/ (lhs: NSLayoutXAxisAnchor,
                  rhs: Utils.UI.Layout.Expression<NSLayoutXAxisAnchor, CGFloat>) -> NSLayoutConstraint {
    Utils.UI.Layout.finalize(constraint: lhs.constraint(greaterThanOrEqualTo: rhs.anchor!, multiplier: rhs.multiplier, constant: rhs.constant), withPriority: rhs.priority)
}

@discardableResult
public func >= (lhs: NSLayoutYAxisAnchor,
                rhs: Utils.UI.Layout.Expression<NSLayoutYAxisAnchor, CGFloat>) -> NSLayoutConstraint {
    lhs />=/ rhs
}

@discardableResult
public func />=/ (lhs: NSLayoutYAxisAnchor,
                  rhs: Utils.UI.Layout.Expression<NSLayoutYAxisAnchor, CGFloat>) -> NSLayoutConstraint {
    Utils.UI.Layout.finalize(constraint: lhs.constraint(greaterThanOrEqualTo: rhs.anchor!, multiplier: rhs.multiplier, constant: rhs.constant), withPriority: rhs.priority)
}

@discardableResult
public func >= (lhs: NSLayoutDimension,
                rhs: Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat>) -> NSLayoutConstraint {
    lhs />=/ rhs
}

@discardableResult
public func />=/ (lhs: NSLayoutDimension,
                  rhs: Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat>) -> NSLayoutConstraint {
    if let anchor = rhs.anchor {
        return Utils.UI.Layout.finalize(constraint: lhs.constraint(greaterThanOrEqualTo: anchor, multiplier: rhs.multiplier, constant: rhs.constant), withPriority: rhs.priority)
    }
    else {
        return Utils.UI.Layout.finalize(constraint: lhs.constraint(greaterThanOrEqualToConstant: rhs.constant), withPriority: rhs.priority)
    }
}

@discardableResult
public func >= (lhs: Utils.UI.Layout.Anchor.Edges,
                rhs: Utils.UI.Layout.Anchor.Edges) -> Utils.UI.Layout.Constraint.Group {
    lhs />=/ rhs
}

@discardableResult
public func />=/ (lhs: Utils.UI.Layout.Anchor.Edges,
                  rhs: Utils.UI.Layout.Anchor.Edges) -> Utils.UI.Layout.Constraint.Group {
    lhs.finalize(constraintsGreaterThanOrEqualToEdges: rhs)
}

@discardableResult
public func >= (lhs: Utils.UI.Layout.Anchor.Edges,
                rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Edges, CGFloat>) -> Utils.UI.Layout.Constraint.Group {
    lhs />=/ rhs
}

@discardableResult
public func />=/ (lhs: Utils.UI.Layout.Anchor.Edges,
                  rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Edges, CGFloat>) -> Utils.UI.Layout.Constraint.Group {
    lhs.finalize(constraintsGreaterThanOrEqualToEdges: rhs.anchor, constant: rhs.constant, priority: rhs.priority)
}

@discardableResult
public func >= (lhs: Utils.UI.Layout.Anchor.Edges,
                rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Edges, UIEdgeInsets>) -> Utils.UI.Layout.Constraint.Group {
    lhs />=/ rhs
}

@discardableResult
public func />=/ (lhs: Utils.UI.Layout.Anchor.Edges,
                  rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Edges, UIEdgeInsets>) -> Utils.UI.Layout.Constraint.Group {
    lhs.finalize(constraintsGreaterThanOrEqualToEdges: rhs.anchor, insets: rhs.constant, priority: rhs.priority)
}

@discardableResult
public func >= <T, U>(lhs: Utils.UI.Layout.Anchor.Pair<T, U>,
                      rhs: Utils.UI.Layout.Anchor.Pair<T, U>) -> Utils.UI.Layout.Constraint.Pair {
    lhs />=/ rhs
}

@discardableResult
public func />=/ <T, U>(lhs: Utils.UI.Layout.Anchor.Pair<T, U>,
                        rhs: Utils.UI.Layout.Anchor.Pair<T, U>) -> Utils.UI.Layout.Constraint.Pair {
    lhs.finalize(constraintsGreaterThanOrEqualToEdges: rhs)
}

@discardableResult
public func >= <T, U>(lhs: Utils.UI.Layout.Anchor.Pair<T, U>,
                      rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Pair<T, U>, CGFloat>) -> Utils.UI.Layout.Constraint.Pair {
    lhs />=/ rhs
}

@discardableResult
public func />=/ <T, U>(lhs: Utils.UI.Layout.Anchor.Pair<T, U>,
                        rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Pair<T, U>, CGFloat>) -> Utils.UI.Layout.Constraint.Pair {
    lhs.finalize(constraintsGreaterThanOrEqualToEdges: rhs.anchor, constant: rhs.constant, priority: rhs.priority)
}

@discardableResult
public func >= (lhs: Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>,
                rhs: CGSize) -> Utils.UI.Layout.Constraint.Pair {
    lhs />=/ rhs
}

@discardableResult
public func />=/ (lhs: Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>,
                  rhs: CGSize) -> Utils.UI.Layout.Constraint.Pair {
    return lhs.finalize(constraintsGreaterThanOrEqualToConstant: rhs)
}

@discardableResult
public func >= (lhs: Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>,
                rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>, CGSize>) -> Utils.UI.Layout.Constraint.Pair {
    lhs />=/ rhs
}

@discardableResult
public func />=/ (lhs: Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>,
                  rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>, CGSize>) -> Utils.UI.Layout.Constraint.Pair {
    lhs.finalize(constraintsGreaterThanOrEqualToConstant: rhs.constant, priority: rhs.priority)
}


// MARK: - Priority

precedencegroup PriorityPrecedence {
    associativity: none
    higherThan: ComparisonPrecedence
    lowerThan: AdditionPrecedence
}

infix operator ~: PriorityPrecedence

@discardableResult
public func ~ <T: BinaryFloatingPoint>(lhs: T,
                                       rhs: Utils.UI.Layout.Priority) -> Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat> {
    .init(constant: CGFloat(lhs), priority: rhs)
}

@discardableResult
public func ~ (lhs: CGSize,
               rhs: Utils.UI.Layout.Priority) -> Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>, CGSize> {
    .init(constant: lhs, priority: rhs)
}

@discardableResult
public func ~ <T>(lhs: T,
                  rhs: Utils.UI.Layout.Priority) -> Utils.UI.Layout.Expression<T, CGFloat> {
    .init(anchor: lhs, constant: 0.0, priority: rhs)
}

@discardableResult
public func ~ <T, U>(lhs: Utils.UI.Layout.Expression<T, U>,
                     rhs: Utils.UI.Layout.Priority) -> Utils.UI.Layout.Expression<T, U> {
    var expr = lhs
    expr.priority = rhs
    return expr
}


// MARK: - Aritmetic

@discardableResult
public func * <T: BinaryFloatingPoint>(lhs: NSLayoutDimension,
                                       rhs: T) -> Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat> {
    Utils.UI.Layout.Expression(anchor: lhs, constant: 0.0, multiplier: CGFloat(rhs))
}

@discardableResult
public func * <T: BinaryFloatingPoint>(lhs: T,
                                       rhs: NSLayoutDimension) -> Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat> {
    .init(anchor: rhs, constant: 0.0, multiplier: CGFloat(lhs))
}

@discardableResult
public func * <T: BinaryFloatingPoint>(lhs: Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat>,
                                       rhs: T) -> Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat> {
    var expr = lhs
    expr.multiplier *= CGFloat(rhs)
    return expr
}

@discardableResult
public func * <T: BinaryFloatingPoint>(lhs: T,
                                       rhs: Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat>) -> Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat> {
    var expr = rhs
    expr.multiplier *= CGFloat(lhs)
    return expr
}

@discardableResult
public func * <T: BinaryFloatingPoint>(lhs: NSLayoutXAxisAnchor,
                                       rhs: T) -> Utils.UI.Layout.Expression<NSLayoutXAxisAnchor, CGFloat> {
    .init(anchor: Optional<NSLayoutXAxisAnchor>.some(lhs), constant: 0.0, multiplier: CGFloat(rhs))
}

@discardableResult
public func * <T: BinaryFloatingPoint>(lhs: T,
                                       rhs: NSLayoutXAxisAnchor) -> Utils.UI.Layout.Expression<NSLayoutXAxisAnchor, CGFloat> {
    .init(anchor: rhs, constant: 0.0, multiplier: CGFloat(lhs))
}

@discardableResult
public func * <T: BinaryFloatingPoint>(lhs: Utils.UI.Layout.Expression<NSLayoutXAxisAnchor, CGFloat>,
                                       rhs: T) -> Utils.UI.Layout.Expression<NSLayoutXAxisAnchor, CGFloat> {
    var expr = lhs
    expr.multiplier *= CGFloat(rhs)
    return expr
}

@discardableResult
public func * <T: BinaryFloatingPoint>(lhs: T,
                                       rhs: Utils.UI.Layout.Expression<NSLayoutXAxisAnchor, CGFloat>) -> Utils.UI.Layout.Expression<NSLayoutXAxisAnchor, CGFloat> {
    var expr = rhs
    expr.multiplier *= CGFloat(lhs)
    return expr
}

@discardableResult
public func * <T: BinaryFloatingPoint>(lhs: NSLayoutYAxisAnchor,
                                       rhs: T) -> Utils.UI.Layout.Expression<NSLayoutYAxisAnchor, CGFloat> {
    .init(anchor: lhs, constant: 0.0, multiplier: CGFloat(rhs))
}

@discardableResult
public func * <T: BinaryFloatingPoint>(lhs: T,
                                       rhs: NSLayoutYAxisAnchor) -> Utils.UI.Layout.Expression<NSLayoutYAxisAnchor, CGFloat> {
    .init(anchor: rhs, constant: 0.0, multiplier: CGFloat(lhs))
}

@discardableResult
public func * <T: BinaryFloatingPoint>(lhs: Utils.UI.Layout.Expression<NSLayoutYAxisAnchor, CGFloat>,
                                       rhs: T) -> Utils.UI.Layout.Expression<NSLayoutYAxisAnchor, CGFloat> {
    var expr = lhs
    expr.multiplier *= CGFloat(rhs)
    return expr
}

@discardableResult public func * <T: BinaryFloatingPoint>(lhs: T,
                                                          rhs: Utils.UI.Layout.Expression<NSLayoutYAxisAnchor, CGFloat>) -> Utils.UI.Layout.Expression<NSLayoutYAxisAnchor, CGFloat> {
    var expr = rhs
    expr.multiplier *= CGFloat(lhs)
    return expr
}

@discardableResult
public func / <T: BinaryFloatingPoint>(lhs: NSLayoutDimension,
                                       rhs: T) -> Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat> {
    .init(anchor: lhs, constant: 0.0, multiplier: 1.0 / CGFloat(rhs))
}

@discardableResult
public func / <T: BinaryFloatingPoint>(lhs: Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat>,
                                       rhs: T) -> Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat> {
    var expr = lhs
    expr.multiplier /= CGFloat(rhs)
    return expr
}

@discardableResult
public func / <T: BinaryFloatingPoint>(lhs: NSLayoutXAxisAnchor,
                                       rhs: T) -> Utils.UI.Layout.Expression<NSLayoutXAxisAnchor, CGFloat> {
    Utils.UI.Layout.Expression(anchor: lhs, constant: 0.0, multiplier: 1.0 / CGFloat(rhs))
}

@discardableResult
public func / <T: BinaryFloatingPoint>(lhs: Utils.UI.Layout.Expression<NSLayoutXAxisAnchor, CGFloat>,
                                       rhs: T) -> Utils.UI.Layout.Expression<NSLayoutXAxisAnchor, CGFloat> {
    var expr = lhs
    expr.multiplier /= CGFloat(rhs)
    return expr
}

@discardableResult
public func / <T: BinaryFloatingPoint>(lhs: NSLayoutYAxisAnchor,
                                       rhs: T) -> Utils.UI.Layout.Expression<NSLayoutYAxisAnchor, CGFloat> {
    .init(anchor: lhs, constant: 0.0, multiplier: 1.0 / CGFloat(rhs))
}

@discardableResult
public func / <T: BinaryFloatingPoint>(lhs: Utils.UI.Layout.Expression<NSLayoutYAxisAnchor, CGFloat>,
                                       rhs: T) -> Utils.UI.Layout.Expression<NSLayoutYAxisAnchor, CGFloat> {
    var expr = lhs
    expr.multiplier /= CGFloat(rhs)
    return expr
}

@discardableResult
public func + <T, U: BinaryFloatingPoint>(lhs: T,
                                          rhs: U) -> Utils.UI.Layout.Expression<T, CGFloat> {
    .init(anchor: lhs, constant: CGFloat(rhs))
}

@discardableResult
public func + <T: BinaryFloatingPoint, U>(lhs: T,
                                          rhs: U) -> Utils.UI.Layout.Expression<U, CGFloat> {
    .init(anchor: rhs, constant: CGFloat(lhs))
}

@discardableResult
public func + <T, U: BinaryFloatingPoint>(lhs: Utils.UI.Layout.Expression<T, CGFloat>,
                                          rhs: U) -> Utils.UI.Layout.Expression<T, CGFloat> {
    var expr = lhs
    expr.constant += CGFloat(rhs)
    return expr
}

@discardableResult
public func + <T: BinaryFloatingPoint, U>(lhs: T,
                                          rhs: Utils.UI.Layout.Expression<U, CGFloat>) -> Utils.UI.Layout.Expression<U, CGFloat> {
    var expr = rhs
    expr.constant += CGFloat(lhs)
    return expr
}

@discardableResult
public func + (lhs: Utils.UI.Layout.Anchor.Edges,
               rhs: UIEdgeInsets) -> Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Edges, UIEdgeInsets> {
    .init(anchor: lhs, constant: rhs)
}

@discardableResult
public func - <T, U: BinaryFloatingPoint>(lhs: T,
                                          rhs: U) -> Utils.UI.Layout.Expression<T, CGFloat> {
    .init(anchor: lhs, constant: -CGFloat(rhs))
}

@discardableResult
public func - <T: BinaryFloatingPoint, U>(lhs: T,
                                          rhs: U) -> Utils.UI.Layout.Expression<U, CGFloat> {
    .init(anchor: rhs, constant: -CGFloat(lhs))
}

@discardableResult
public func - <T, U: BinaryFloatingPoint>(lhs: Utils.UI.Layout.Expression<T, CGFloat>,
                                          rhs: U) -> Utils.UI.Layout.Expression<T, CGFloat> {
    var expr = lhs
    expr.constant -= CGFloat(rhs)
    return expr
}

@discardableResult
public func - <T: BinaryFloatingPoint, U>(lhs: T,
                                          rhs: Utils.UI.Layout.Expression<U, CGFloat>) -> Utils.UI.Layout.Expression<U, CGFloat> {
    var expr = rhs
    expr.constant -= CGFloat(lhs)
    return expr
}

@discardableResult
public func - (lhs: Utils.UI.Layout.Anchor.Edges,
               rhs: UIEdgeInsets) -> Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Edges, UIEdgeInsets> {
    .init(anchor: lhs, constant: -rhs)
}
