////
////  Layout.swift
////  
////
////  Created by Miroslav Yozov on 7.07.22.
////
//
//import UIKit
//
//// MARK: - namespaces
//extension Utils.UI {
//    public struct Layout { }
//}
//
//extension Utils.UI.Layout {
//    public struct Constraint { }
//}
//
//extension Utils.UI.Layout {
//    public struct Anchor { }
//}
//
//extension Utils.UI.Layout {
//    public struct Expression<T: UtilsUILayoutAnchorType, U: UtilsUILayoutConstantType> {
//        public var anchor: T?
//        public var constant: U
//        public var multiplier: CGFloat
//        public var priority: Priority
//
//        internal init(anchor a: T? = nil, constant c: U, multiplier m: CGFloat = 1.0, priority p: Priority = .required) {
//            anchor = a
//            constant = c
//            multiplier = m
//            priority = p
//        }
//    }
//}
//
//
//extension Utils.UI.Layout.Anchor {
//    public struct Pair<T: UtilsUILayoutAnchorType, U: UtilsUILayoutAnchorType>: UtilsUILayoutAnchorType {
//        public var first: T
//        public var second: U
//
//        internal init(first f: T, second s: U) {
//            first = f
//            second = s
//        }
//        
//        func finalize(constraintsEqualToConstant size: CGSize, priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Constraint.Pair {
//            constraints(forConstant: size, priority: priority, builder: Utils.UI.Layout.Constraint.Builder.equality);
//        }
//
//        func finalize(constraintsLessThanOrEqualToConstant size: CGSize, priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Constraint.Pair {
//            constraints(forConstant: size, priority: priority, builder: Utils.UI.Layout.Constraint.Builder.lessThanOrEqual);
//        }
//
//        func finalize(constraintsGreaterThanOrEqualToConstant size: CGSize, priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Constraint.Pair {
//            constraints(forConstant: size, priority: priority, builder: Utils.UI.Layout.Constraint.Builder.greaterThanOrEqual);
//        }
//
//        func finalize(constraintsEqualToEdges anchor: Utils.UI.Layout.Anchor.Pair<T, U>?, constant c: CGFloat = 0.0, priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Constraint.Pair {
//            constraints(forAnchors: anchor, constant: c, priority: priority, builder: Utils.UI.Layout.Constraint.Builder.equality)
//        }
//
//        func finalize(constraintsLessThanOrEqualToEdges anchor: Utils.UI.Layout.Anchor.Pair<T, U>?, constant c: CGFloat = 0.0, priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Constraint.Pair {
//            constraints(forAnchors: anchor, constant: c, priority: priority, builder: Utils.UI.Layout.Constraint.Builder.lessThanOrEqual)
//        }
//
//        func finalize(constraintsGreaterThanOrEqualToEdges anchor: Utils.UI.Layout.Anchor.Pair<T, U>?, constant c: CGFloat = 0.0, priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Constraint.Pair {
//            constraints(forAnchors: anchor, constant: c, priority: priority, builder: Utils.UI.Layout.Constraint.Builder.greaterThanOrEqual)
//        }
//
//        func constraints(forConstant size: CGSize, priority: Priority, builder: Utils.UI.Layout.Constraint.Pair) -> Utils.UI.Layout.Constraint.Pair {
//            var constraints: Utils.UI.Layout.Constraint.Pair!
//
//            /*
//            performInBatch {
//                switch (first, second) {
//                case let (first as NSLayoutDimension, second as NSLayoutDimension):
//                    constraints = ConstraintPair(
//                        first: builder.dimensionBuilder(first, size.width ~ priority),
//                        second: builder.dimensionBuilder(second, size.height ~ priority)
//                    )
//                default:
//                    preconditionFailure("Only AnchorPair<NSLayoutDimension, NSLayoutDimension> can be constrained to a constant size.")
//                }
//            }
//            */
//            
//            return constraints;
//        }
//
//        func constraints(forAnchors anchors: Utils.UI.Layout.Anchor.Pair<T, U>?, constant c: CGFloat, priority: Utils.UI.Layout.Priority, builder: Utils.UI.Layout.Constraint.Builder) -> Utils.UI.Layout.Constraint.Pair {
//            return constraints(forAnchors: anchors, firstConstant: c, secondConstant: c, priority: priority, builder: builder)
//        }
//
//        func constraints(forAnchors anchors: Utils.UI.Layout.Anchor.Pair<T, U>?, firstConstant c1: CGFloat, secondConstant c2: CGFloat, priority: Priority, builder: Utils.UI.Layout.Constraint.Builder) -> Utils.UI.Layout.Constraint.Pair {
//            guard let anchors = anchors else {
//                preconditionFailure("Encountered nil edge anchors, indicating internal inconsistency of this API.")
//            }
//
//            var constraints: Utils.UI.Layout.Constraint.Pair!
//
//            /*
//            performInBatch {
//                switch (first, anchors.first, second, anchors.second) {
//                // Leading, Trailing
//                case let (firstX as NSLayoutXAxisAnchor, otherFirstX as NSLayoutXAxisAnchor,
//                          secondX as NSLayoutXAxisAnchor, otherSecondX as NSLayoutXAxisAnchor):
//                    constraints = ConstraintPair(
//                        first: builder.leadingBuilder(firstX, otherFirstX + c1 ~ priority),
//                        second: builder.trailingBuilder(secondX, otherSecondX - c2 ~ priority)
//                    )
//                // Top, Bottom
//                case let (firstY as NSLayoutYAxisAnchor, otherFirstY as NSLayoutYAxisAnchor,
//                          secondY as NSLayoutYAxisAnchor, otherSecondY as NSLayoutYAxisAnchor):
//                    constraints = ConstraintPair(
//                        first: builder.topBuilder(firstY, otherFirstY + c1 ~ priority),
//                        second: builder.bottomBuilder(secondY, otherSecondY - c2 ~ priority)
//                    )
//                // CenterX, CenterY
//                case let (firstX as NSLayoutXAxisAnchor, otherFirstX as NSLayoutXAxisAnchor,
//                          firstY as NSLayoutYAxisAnchor, otherFirstY as NSLayoutYAxisAnchor):
//                    constraints = ConstraintPair(
//                        first: builder.centerXBuilder(firstX, otherFirstX + c1 ~ priority),
//                        second: builder.centerYBuilder(firstY, otherFirstY + c2 ~ priority)
//                    )
//                // Width, Height
//                case let (first as NSLayoutDimension, otherFirst as NSLayoutDimension,
//                          second as NSLayoutDimension, otherSecond as NSLayoutDimension):
//                    constraints = ConstraintPair(
//                        first: builder.dimensionBuilder(first, otherFirst + c1 ~ priority),
//                        second: builder.dimensionBuilder(second, otherSecond + c2 ~ priority)
//                    )
//                default:
//                    preconditionFailure("Constrained anchors must match in either axis or type.")
//                }
//            }
//             */
//            
//            return constraints
//        }
//        
//        
//        func finalize(constraintsEqualToConstant size: CGSize, priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Constraint.Pair {
//            constraints(forConstant: size, priority: priority, builder: Utils.UI.Layout.Constraint.Builder.equality);
//        }
//
//        func finalize(constraintsLessThanOrEqualToConstant size: CGSize, priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Constraint.Pair {
//            constraints(forConstant: size, priority: priority, builder: Utils.UI.Layout.Constraint.Builder.lessThanOrEqual);
//        }
//
//        func finalize(constraintsGreaterThanOrEqualToConstant size: CGSize, priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Constraint.Pair {
//            constraints(forConstant: size, priority: priority, builder: Utils.UI.Layout.Constraint.Builder.greaterThanOrEqual);
//        }
//
//        func finalize(constraintsEqualToEdges anchor: Utils.UI.Layout.Anchor.Pair<T, U>?, constant c: CGFloat = 0.0, priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Constraint.Pair {
//            constraints(forAnchors: anchor, constant: c, priority: priority, builder: Utils.UI.Layout.Constraint.Builder.equality)
//        }
//
//        func finalize(constraintsLessThanOrEqualToEdges anchor: Utils.UI.Layout.Anchor.Pair<T, U>?, constant c: CGFloat = 0.0, priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Constraint.Pair {
//            constraints(forAnchors: anchor, constant: c, priority: priority, builder: Utils.UI.Layout.Constraint.Builder.lessThanOrEqual)
//        }
//
//        func finalize(constraintsGreaterThanOrEqualToEdges anchor: Utils.UI.Layout.Anchor.Pair<T, U>?, constant c: CGFloat = 0.0, priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Constraint.Pair {
//            constraints(forAnchors: anchor, constant: c, priority: priority, builder: Utils.UI.Layout.Constraint.Builder.greaterThanOrEqual)
//        }
//
//        func constraints(forConstant size: CGSize, priority: Priority, builder: Utils.UI.Layout.Constraint.Pair) -> Utils.UI.Layout.Constraint.Pair {
//            var constraints: Utils.UI.Layout.Constraint.Pair!
//
//            /*
//            performInBatch {
//                switch (first, second) {
//                case let (first as NSLayoutDimension, second as NSLayoutDimension):
//                    constraints = ConstraintPair(
//                        first: builder.dimensionBuilder(first, size.width ~ priority),
//                        second: builder.dimensionBuilder(second, size.height ~ priority)
//                    )
//                default:
//                    preconditionFailure("Only AnchorPair<NSLayoutDimension, NSLayoutDimension> can be constrained to a constant size.")
//                }
//            }
//            */
//            
//            return constraints;
//        }
//
//        func constraints(forAnchors anchors: Utils.UI.Layout.Anchor.Pair<T, U>?, constant c: CGFloat, priority: Utils.UI.Layout.Priority, builder: Utils.UI.Layout.Constraint.Builder) -> Utils.UI.Layout.Constraint.Pair {
//            return constraints(forAnchors: anchors, firstConstant: c, secondConstant: c, priority: priority, builder: builder)
//        }
//
//        func constraints(forAnchors anchors: Utils.UI.Layout.Anchor.Pair<T, U>?, firstConstant c1: CGFloat, secondConstant c2: CGFloat, priority: Priority, builder: Utils.UI.Layout.Constraint.Builder) -> Utils.UI.Layout.Constraint.Pair {
//            guard let anchors = anchors else {
//                preconditionFailure("Encountered nil edge anchors, indicating internal inconsistency of this API.")
//            }
//
//            var constraints: Utils.UI.Layout.Constraint.Pair!
//
//            /*
//            performInBatch {
//                switch (first, anchors.first, second, anchors.second) {
//                // Leading, Trailing
//                case let (firstX as NSLayoutXAxisAnchor, otherFirstX as NSLayoutXAxisAnchor,
//                          secondX as NSLayoutXAxisAnchor, otherSecondX as NSLayoutXAxisAnchor):
//                    constraints = ConstraintPair(
//                        first: builder.leadingBuilder(firstX, otherFirstX + c1 ~ priority),
//                        second: builder.trailingBuilder(secondX, otherSecondX - c2 ~ priority)
//                    )
//                // Top, Bottom
//                case let (firstY as NSLayoutYAxisAnchor, otherFirstY as NSLayoutYAxisAnchor,
//                          secondY as NSLayoutYAxisAnchor, otherSecondY as NSLayoutYAxisAnchor):
//                    constraints = ConstraintPair(
//                        first: builder.topBuilder(firstY, otherFirstY + c1 ~ priority),
//                        second: builder.bottomBuilder(secondY, otherSecondY - c2 ~ priority)
//                    )
//                // CenterX, CenterY
//                case let (firstX as NSLayoutXAxisAnchor, otherFirstX as NSLayoutXAxisAnchor,
//                          firstY as NSLayoutYAxisAnchor, otherFirstY as NSLayoutYAxisAnchor):
//                    constraints = ConstraintPair(
//                        first: builder.centerXBuilder(firstX, otherFirstX + c1 ~ priority),
//                        second: builder.centerYBuilder(firstY, otherFirstY + c2 ~ priority)
//                    )
//                // Width, Height
//                case let (first as NSLayoutDimension, otherFirst as NSLayoutDimension,
//                          second as NSLayoutDimension, otherSecond as NSLayoutDimension):
//                    constraints = ConstraintPair(
//                        first: builder.dimensionBuilder(first, otherFirst + c1 ~ priority),
//                        second: builder.dimensionBuilder(second, otherSecond + c2 ~ priority)
//                    )
//                default:
//                    preconditionFailure("Constrained anchors must match in either axis or type.")
//                }
//            }
//             */
//            
//            return constraints
//        }
//    }
//}
//
//extension Utils.UI.Layout.Anchor {
//    public struct Edges: UtilsUILayoutAnchorType {
//        public var horizontalAnchors: Pair<NSLayoutXAxisAnchor, NSLayoutXAxisAnchor>
//        public var verticalAnchors: Pair<NSLayoutYAxisAnchor, NSLayoutYAxisAnchor>
//        
//        init(horizontal: Pair<NSLayoutXAxisAnchor, NSLayoutXAxisAnchor>, vertical: Pair<NSLayoutYAxisAnchor, NSLayoutYAxisAnchor>) {
//            horizontalAnchors = horizontal
//            verticalAnchors = vertical
//        }
//
//        func finalize(constraintsEqualToEdges anchor: Edges?, insets: UIEdgeInsets, priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Constraint.Group {
//            constraints(forAnchors: anchor, insets: insets, priority: priority, builder: Utils.UI.Layout.Constraint.Builder.equality)
//        }
//
//        func finalize(constraintsLessThanOrEqualToEdges anchor: Edges?, insets: UIEdgeInsets, priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Constraint.Group {
//            constraints(forAnchors: anchor, insets: insets, priority: priority, builder: Utils.UI.Layout.Constraint.Builder.lessThanOrEqual)
//        }
//
//        func finalize(constraintsGreaterThanOrEqualToEdges anchor: Edges?, insets: UIEdgeInsets, priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Constraint.Group {
//            constraints(forAnchors: anchor, insets: insets, priority: priority, builder: Utils.UI.Layout.Constraint.Builder.greaterThanOrEqual)
//        }
//
//        func finalize(constraintsEqualToEdges anchor: Edges?, constant c: CGFloat = 0.0, priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Constraint.Group {
//            constraints(forAnchors: anchor, insets: UIEdgeInsets(constant: c), priority: priority, builder: Utils.UI.Layout.Constraint.Builder.equality)
//        }
//
//        func finalize(constraintsLessThanOrEqualToEdges anchor: Edges?, constant c: CGFloat = 0.0, priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Constraint.Group {
//            constraints(forAnchors: anchor, insets: UIEdgeInsets(constant: c), priority: priority, builder: Utils.UI.Layout.Constraint.Builder.lessThanOrEqual)
//        }
//
//        func finalize(constraintsGreaterThanOrEqualToEdges anchor: Edges?, constant c: CGFloat = 0.0, priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Constraint.Group {
//            constraints(forAnchors: anchor, insets: UIEdgeInsets(constant: c), priority: priority, builder: Utils.UI.Layout.Constraint.Builder.greaterThanOrEqual)
//        }
//
//        func constraints(forAnchors anchors: Edges?, insets: UIEdgeInsets, priority: Utils.UI.Layout.Priority, builder: Utils.UI.Layout.Constraint.Builder) -> Utils.UI.Layout.Constraint.Group {
//            guard let anchors = anchors else {
//                preconditionFailure("Encountered nil edge anchors, indicating internal inconsistency of this API.")
//            }
//
//            var constraints: Utils.UI.Layout.Constraint.Group!
//
//            /*
//            performInBatch {
//                let horizontalConstraints = horizontalAnchors.constraints(forAnchors: anchors.horizontalAnchors, firstConstant: insets.left, secondConstant: insets.right, priority: priority, builder: builder)
//                let verticalConstraints = verticalAnchors.constraints(forAnchors: anchors.verticalAnchors, firstConstant: insets.top, secondConstant: insets.bottom, priority: priority, builder: builder)
//                constraints = ConstraintGroup(
//                    top: verticalConstraints.first,
//                    leading: horizontalConstraints.first,
//                    bottom: verticalConstraints.second,
//                    trailing: horizontalConstraints.second
//                )
//            }
//            */
//
//            return constraints
//        }
//        
//        
//        
//        
//        
//    }
//}
//
//extension Utils.UI.Layout.Constraint {
//    public struct Pair {
//        public var first: NSLayoutConstraint
//        public var second: NSLayoutConstraint
//    }
//}
//
//
//extension Utils.UI.Layout.Constraint {
//    public struct Group {
//        public var top: NSLayoutConstraint
//        public var leading: NSLayoutConstraint
//        public var bottom: NSLayoutConstraint
//        public var trailing: NSLayoutConstraint
//
//        public var horizontal: [NSLayoutConstraint] {
//            [leading, trailing]
//        }
//
//        public var vertical: [NSLayoutConstraint] {
//            [top, bottom]
//        }
//
//        public var all: [NSLayoutConstraint] {
//            [top, leading, bottom, trailing]
//        }
//    }
//}
//
//extension Utils.UI.Layout.Constraint {
//    internal struct Builder {
//        typealias Horizontal = (NSLayoutXAxisAnchor, Utils.UI.Layout.Expression<NSLayoutXAxisAnchor, CGFloat>) -> NSLayoutConstraint
//        typealias Vertical = (NSLayoutYAxisAnchor, Utils.UI.Layout.Expression<NSLayoutYAxisAnchor, CGFloat>) -> NSLayoutConstraint
//        typealias Dimension = (NSLayoutDimension, Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat>) -> NSLayoutConstraint
//
//        static let equality = Builder(horizontal: ==, vertical: ==, dimension: ==)
//        static let lessThanOrEqual = Builder(leading: <=, top: <=, trailing: >=, bottom: >=, centerX: <=, centerY: <=, dimension: <=)
//        static let greaterThanOrEqual = Builder(leading: >=, top: >=, trailing: <=, bottom: <=, centerX: >=, centerY: >=, dimension: >=)
//
//        var topBuilder: Vertical
//        var leadingBuilder: Horizontal
//        var bottomBuilder: Vertical
//        var trailingBuilder: Horizontal
//        var centerYBuilder: Vertical
//        var centerXBuilder: Horizontal
//        var dimensionBuilder: Dimension
//
//        init(horizontal: @escaping Horizontal, vertical: @escaping Vertical, dimension: @escaping Dimension) {
//            topBuilder = vertical
//            leadingBuilder = horizontal
//            bottomBuilder = vertical
//            trailingBuilder = horizontal
//            centerYBuilder = vertical
//            centerXBuilder = horizontal
//            dimensionBuilder = dimension
//        }
//
//        init(leading: @escaping Horizontal, top: @escaping Vertical, trailing: @escaping Horizontal, bottom: @escaping Vertical, centerX: @escaping Horizontal, centerY: @escaping Vertical, dimension: @escaping Dimension) {
//            leadingBuilder = leading
//            topBuilder = top
//            trailingBuilder = trailing
//            bottomBuilder = bottom
//            centerYBuilder = centerY
//            centerXBuilder = centerX
//            dimensionBuilder = dimension
//        }
//    }
//}
//
//
//// MARK: - Equality Constraints
//
//infix operator /==/: ComparisonPrecedence
//
//@discardableResult
//public func == <T: BinaryFloatingPoint>(lhs: NSLayoutDimension,
//                                        rhs: T) -> NSLayoutConstraint {
//    lhs /==/ rhs
//}
//
//@discardableResult
//public func /==/ <T: BinaryFloatingPoint>(lhs: NSLayoutDimension,
//                                          rhs: T) -> NSLayoutConstraint {
//    finalize(constraint: lhs.constraint(equalToConstant: CGFloat(rhs)))
//}
//
//@discardableResult
//public func == (lhs: NSLayoutXAxisAnchor, rhs: NSLayoutXAxisAnchor) -> NSLayoutConstraint {
//    lhs /==/ rhs
//}
//
//@discardableResult
//public func /==/ (lhs: NSLayoutXAxisAnchor, rhs: NSLayoutXAxisAnchor) -> NSLayoutConstraint {
//    finalize(constraint: lhs.constraint(equalTo: rhs))
//}
//
//@discardableResult
//public func == (lhs: NSLayoutYAxisAnchor, rhs: NSLayoutYAxisAnchor) -> NSLayoutConstraint {
//    lhs /==/ rhs
//}
//
//@discardableResult
//public func /==/ (lhs: NSLayoutYAxisAnchor,
//                  rhs: NSLayoutYAxisAnchor) -> NSLayoutConstraint {
//    finalize(constraint: lhs.constraint(equalTo: rhs))
//}
//
//@discardableResult
//public func == (lhs: NSLayoutDimension,
//                rhs: NSLayoutDimension) -> NSLayoutConstraint {
//    lhs /==/ rhs
//}
//
//@discardableResult
//public func /==/ (lhs: NSLayoutDimension,
//                  rhs: NSLayoutDimension) -> NSLayoutConstraint {
//    return finalize(constraint: lhs.constraint(equalTo: rhs))
//}
//
//@discardableResult
//public func == (lhs: NSLayoutXAxisAnchor,
//                rhs: Utils.UI.Layout.Expression<NSLayoutXAxisAnchor, CGFloat>) -> NSLayoutConstraint {
//    lhs /==/ rhs
//}
//
//@discardableResult
//public func /==/ (lhs: NSLayoutXAxisAnchor,
//                  rhs: Utils.UI.Layout.Expression<NSLayoutXAxisAnchor, CGFloat>) -> NSLayoutConstraint {
//    finalize(constraint: lhs.constraint(equalTo: rhs.anchor!, multiplier: rhs.multiplier, constant: rhs.constant), withPriority: rhs.priority)
//}
//
//@discardableResult
//public func == (lhs: NSLayoutYAxisAnchor, rhs: Utils.UI.Layout.Expression<NSLayoutYAxisAnchor, CGFloat>) -> NSLayoutConstraint {
//    return lhs /==/ rhs
//}
//
//@discardableResult
//public func /==/ (lhs: NSLayoutYAxisAnchor, rhs: Utils.UI.Layout.Expression<NSLayoutYAxisAnchor, CGFloat>) -> NSLayoutConstraint {
//    return finalize(constraint: lhs.constraint(equalTo: rhs.anchor!, multiplier: rhs.multiplier, constant: rhs.constant), withPriority: rhs.priority)
//}
//
//@discardableResult
//public func == (lhs: NSLayoutDimension,
//                rhs: Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat>) -> NSLayoutConstraint {
//    lhs /==/ rhs
//}
//
//@discardableResult
//public func /==/ (lhs: NSLayoutDimension,
//                  rhs: Utils.UI.Layout.Expression<NSLayoutDimension, CGFloat>) -> NSLayoutConstraint {
//    if let anchor = rhs.anchor {
//        return finalize(constraint: lhs.constraint(equalTo: anchor, multiplier: rhs.multiplier, constant: rhs.constant), withPriority: rhs.priority)
//    }
//    else {
//        return finalize(constraint: lhs.constraint(equalToConstant: rhs.constant), withPriority: rhs.priority)
//    }
//}
//
//@discardableResult
//public func == (lhs: Utils.UI.Layout.Anchor.Edges,
//                rhs: Utils.UI.Layout.Anchor.Edges) -> Utils.UI.Layout.Constraint.Group {
//    lhs /==/ rhs
//}
//
//@discardableResult
//public func /==/ (lhs: Utils.UI.Layout.Anchor.Edges,
//                  rhs: Utils.UI.Layout.Anchor.Edges) -> Utils.UI.Layout.Constraint.Group {
//    lhs.finalize(constraintsEqualToEdges: rhs)
//}
//
//@discardableResult
//public func == (lhs: Utils.UI.Layout.Anchor.Edges,
//                rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Edges, CGFloat>) -> Utils.UI.Layout.Constraint.Group {
//    lhs /==/ rhs
//}
//
//@discardableResult
//public func /==/ (lhs: Utils.UI.Layout.Anchor.Edges,
//                  rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Edges, CGFloat>) -> Utils.UI.Layout.Constraint.Group {
//    lhs.finalize(constraintsEqualToEdges: rhs.anchor, constant: rhs.constant, priority: rhs.priority)
//}
//
//@discardableResult
//public func == (lhs: Utils.UI.Layout.Anchor.Edges,
//                rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Edges, UIEdgeInsets>) -> Utils.UI.Layout.Constraint.Group {
//    lhs /==/ rhs
//}
//
//@discardableResult
//public func /==/ (lhs: Utils.UI.Layout.Anchor.Edges, rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Edges, UIEdgeInsets>) -> Utils.UI.Layout.Constraint.Group {
//    lhs.finalize(constraintsEqualToEdges: rhs.anchor, insets: rhs.constant, priority: rhs.priority)
//}
//
//@discardableResult
//public func == <T, U>(lhs: Utils.UI.Layout.Anchor.Pair<T, U>, rhs: Utils.UI.Layout.Anchor.Pair<T, U>) -> Utils.UI.Layout.Constraint.Pair {
//    lhs /==/ rhs
//}
//
//@discardableResult
//public func /==/ <T, U>(lhs: Utils.UI.Layout.Anchor.Pair<T, U>, rhs: Utils.UI.Layout.Anchor.Pair<T, U>) -> Utils.UI.Layout.Constraint.Pair {
//    return lhs.finalize(constraintsEqualToEdges: rhs)
//}
//
//@discardableResult
//public func == <T, U>(lhs: Utils.UI.Layout.Anchor.Pair<T, U>,
//                      rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Pair<T, U>, CGFloat>) -> Utils.UI.Layout.Constraint.Pair {
//    lhs /==/ rhs
//}
//
//@discardableResult
//public func /==/ <T, U>(lhs: Utils.UI.Layout.Anchor.Pair<T, U>,
//                        rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Pair<T, U>, CGFloat>) -> Utils.UI.Layout.Constraint.Pair {
//    lhs.finalize(constraintsEqualToEdges: rhs.anchor, constant: rhs.constant, priority: rhs.priority)
//}
//
//@discardableResult
//public func == (lhs: Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>,
//                rhs: CGSize) -> Utils.UI.Layout.Constraint.Pair {
//    lhs /==/ rhs
//}
//
//@discardableResult
//public func /==/ (lhs: Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>,
//                  rhs: CGSize) -> Utils.UI.Layout.Constraint.Pair {
//    lhs.finalize(constraintsEqualToConstant: rhs)
//}
//
//@discardableResult
//public func == (lhs: Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>,
//                rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>, CGSize>) -> Utils.UI.Layout.Constraint.Pair {
//    lhs /==/ rhs
//}
//
//@discardableResult
//public func /==/ (lhs: Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>,
//                  rhs: Utils.UI.Layout.Expression<Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension>, CGSize>) -> Utils.UI.Layout.Constraint.Pair {
//    lhs.finalize(constraintsEqualToConstant: rhs.constant, priority: rhs.priority)
//}
