//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 8.07.22.
//

import UIKit

extension Utils.UI.Layout {
    public struct Anchor { }
}

extension Utils.UI.Layout.Anchor {
    public struct Pair<T: UtilsUILayoutAnchorType, U: UtilsUILayoutAnchorType>: UtilsUILayoutAnchorType {
        typealias Constraint = Utils.UI.Layout.Constraint
        typealias Priority = Utils.UI.Layout.Priority
        
        public var first: T
        public var second: U

        internal init(first f: T, second s: U) {
            first = f
            second = s
        }
        
        func finalize(constraintsEqualToConstant size: CGSize, priority: Priority = .required) -> Constraint.Pair {
            constraints(forConstant: size, priority: priority, builder: Constraint.Builder.equality);
        }

        func finalize(constraintsLessThanOrEqualToConstant size: CGSize, priority: Priority = .required) -> Constraint.Pair {
            constraints(forConstant: size, priority: priority, builder: Constraint.Builder.lessThanOrEqual);
        }

        func finalize(constraintsGreaterThanOrEqualToConstant size: CGSize, priority: Priority = .required) -> Constraint.Pair {
            constraints(forConstant: size, priority: priority, builder: Constraint.Builder.greaterThanOrEqual);
        }

        func finalize(constraintsEqualToEdges anchor: Pair<T, U>?, constant c: CGFloat = 0.0, priority: Priority = .required) -> Constraint.Pair {
            constraints(forAnchors: anchor, constant: c, priority: priority, builder: Constraint.Builder.equality)
        }

        func finalize(constraintsLessThanOrEqualToEdges anchor: Pair<T, U>?, constant c: CGFloat = 0.0, priority: Priority = .required) -> Constraint.Pair {
            constraints(forAnchors: anchor, constant: c, priority: priority, builder: Constraint.Builder.lessThanOrEqual)
        }

        func finalize(constraintsGreaterThanOrEqualToEdges anchor: Pair<T, U>?, constant c: CGFloat = 0.0, priority: Priority = .required) -> Constraint.Pair {
            constraints(forAnchors: anchor, constant: c, priority: priority, builder: Constraint.Builder.greaterThanOrEqual)
        }

        func constraints(forConstant size: CGSize, priority: Priority, builder: Constraint.Builder) -> Constraint.Pair {
            var constraints: Constraint.Pair!

            Utils.UI.Layout.performInBatch {
                switch (first, second) {
                case let (first as NSLayoutDimension, second as NSLayoutDimension):
                    constraints = .init(first: builder.dimensionBuilder(first, size.width ~ priority),
                                        second: builder.dimensionBuilder(second, size.height ~ priority))
                default:
                    preconditionFailure("Only Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension> can be constrained to a constant size.")
                }
            }
            
            return constraints
        }

        func constraints(forAnchors anchors: Pair<T, U>?, constant c: CGFloat, priority: Priority, builder: Constraint.Builder) -> Constraint.Pair {
            constraints(forAnchors: anchors, firstConstant: c, secondConstant: c, priority: priority, builder: builder)
        }

        func constraints(forAnchors anchors: Pair<T, U>?, firstConstant c1: CGFloat, secondConstant c2: CGFloat, priority: Priority, builder: Constraint.Builder) -> Constraint.Pair {
            guard let anchors = anchors else {
                preconditionFailure("Encountered nil edge anchors, indicating internal inconsistency of this API.")
            }

            var constraints: Constraint.Pair!

            Utils.UI.Layout.performInBatch {
                switch (first, anchors.first, second, anchors.second) {
                // Leading, Trailing
                case let (firstX as NSLayoutXAxisAnchor, otherFirstX as NSLayoutXAxisAnchor,
                          secondX as NSLayoutXAxisAnchor, otherSecondX as NSLayoutXAxisAnchor):
                    constraints = .init(first: builder.leadingBuilder(firstX, otherFirstX + c1 ~ priority),
                                        second: builder.trailingBuilder(secondX, otherSecondX - c2 ~ priority))
                // Top, Bottom
                case let (firstY as NSLayoutYAxisAnchor, otherFirstY as NSLayoutYAxisAnchor,
                          secondY as NSLayoutYAxisAnchor, otherSecondY as NSLayoutYAxisAnchor):
                    constraints = .init(first: builder.topBuilder(firstY, otherFirstY + c1 ~ priority),
                                        second: builder.bottomBuilder(secondY, otherSecondY - c2 ~ priority))
                // CenterX, CenterY
                case let (firstX as NSLayoutXAxisAnchor, otherFirstX as NSLayoutXAxisAnchor,
                          firstY as NSLayoutYAxisAnchor, otherFirstY as NSLayoutYAxisAnchor):
                    constraints = .init(first: builder.centerXBuilder(firstX, otherFirstX + c1 ~ priority),
                                        second: builder.centerYBuilder(firstY, otherFirstY + c2 ~ priority))
                // Width, Height
                case let (first as NSLayoutDimension, otherFirst as NSLayoutDimension,
                          second as NSLayoutDimension, otherSecond as NSLayoutDimension):
                    constraints = .init(first: builder.dimensionBuilder(first, otherFirst + c1 ~ priority),
                                        second: builder.dimensionBuilder(second, otherSecond + c2 ~ priority))
                default:
                    preconditionFailure("Constrained anchors must match in either axis or type.")
                }
            }
            
            return constraints
        }
    }
}

extension Utils.UI.Layout.Anchor {
    public struct Edges: UtilsUILayoutAnchorType {
        typealias Constraint = Utils.UI.Layout.Constraint
        typealias Priority = Utils.UI.Layout.Priority
        
        public var horizontalAnchors: Pair<NSLayoutXAxisAnchor, NSLayoutXAxisAnchor>
        public var verticalAnchors: Pair<NSLayoutYAxisAnchor, NSLayoutYAxisAnchor>
        
        init(horizontal: Pair<NSLayoutXAxisAnchor, NSLayoutXAxisAnchor>, vertical: Pair<NSLayoutYAxisAnchor, NSLayoutYAxisAnchor>) {
            horizontalAnchors = horizontal
            verticalAnchors = vertical
        }
        
        func finalize(constraintsEqualToEdges anchor: Edges?, insets: UIEdgeInsets, priority: Priority = .required) -> Constraint.Group {
            constraints(forAnchors: anchor, insets: insets, priority: priority, builder: Constraint.Builder.equality)
        }

        func finalize(constraintsLessThanOrEqualToEdges anchor: Edges?, insets: UIEdgeInsets, priority: Priority = .required) -> Constraint.Group {
            constraints(forAnchors: anchor, insets: insets, priority: priority, builder: Constraint.Builder.lessThanOrEqual)
        }

        func finalize(constraintsGreaterThanOrEqualToEdges anchor: Edges?, insets: UIEdgeInsets, priority: Priority = .required) -> Constraint.Group {
            constraints(forAnchors: anchor, insets: insets, priority: priority, builder: Constraint.Builder.greaterThanOrEqual)
        }

        func finalize(constraintsEqualToEdges anchor: Edges?, constant c: CGFloat = 0.0, priority: Priority = .required) -> Constraint.Group {
            constraints(forAnchors: anchor, insets: UIEdgeInsets(constant: c), priority: priority, builder: Constraint.Builder.equality)
        }

        func finalize(constraintsLessThanOrEqualToEdges anchor: Edges?, constant c: CGFloat = 0.0, priority: Priority = .required) -> Constraint.Group {
            constraints(forAnchors: anchor, insets: UIEdgeInsets(constant: c), priority: priority, builder: Constraint.Builder.lessThanOrEqual)
        }

        func finalize(constraintsGreaterThanOrEqualToEdges anchor: Edges?, constant c: CGFloat = 0.0, priority: Priority = .required) -> Constraint.Group {
            constraints(forAnchors: anchor, insets: UIEdgeInsets(constant: c), priority: priority, builder: Constraint.Builder.greaterThanOrEqual)
        }

        func constraints(forAnchors anchors: Edges?, insets: UIEdgeInsets, priority: Priority, builder: Constraint.Builder) -> Constraint.Group {
            guard let anchors = anchors else {
                preconditionFailure("Encountered nil edge anchors, indicating internal inconsistency of this API.")
            }

            var constraints: Constraint.Group!

            Utils.UI.Layout.performInBatch {
                let horizontalConstraints = horizontalAnchors.constraints(forAnchors: anchors.horizontalAnchors, firstConstant: insets.left, secondConstant: insets.right, priority: priority, builder: builder)
                let verticalConstraints = verticalAnchors.constraints(forAnchors: anchors.verticalAnchors, firstConstant: insets.top, secondConstant: insets.bottom, priority: priority, builder: builder)
                constraints = .init(top: verticalConstraints.first,
                                    leading: horizontalConstraints.first,
                                    bottom: verticalConstraints.second,
                                    trailing: horizontalConstraints.second)
            }

            return constraints
        }
    }
}

extension Utils.UI.Layout.Anchor {
    public struct Group {
        let anchors: UtilsUIAnchorsCompatible
        
        public init(_ a: UtilsUIAnchorsCompatible) {
            anchors = a
        }
        
        public var leading  : NSLayoutXAxisAnchor { anchors.leadingAnchor }
        public var trailing : NSLayoutXAxisAnchor { anchors.trailingAnchor }

        public var left  : NSLayoutXAxisAnchor { anchors.leftAnchor }
        public var right : NSLayoutXAxisAnchor { anchors.rightAnchor }

        public var top    : NSLayoutYAxisAnchor { anchors.topAnchor }
        public var bottom : NSLayoutYAxisAnchor { anchors.bottomAnchor }

        public var width  : NSLayoutDimension { anchors.widthAnchor }
        public var height : NSLayoutDimension { anchors.heightAnchor }

        public var centerX : NSLayoutXAxisAnchor { anchors.centerXAnchor }
        public var centerY : NSLayoutYAxisAnchor { anchors.centerYAnchor }
        
        public var horizontal : Utils.UI.Layout.Anchor.Pair<NSLayoutXAxisAnchor, NSLayoutXAxisAnchor> { anchors.horizontalAnchors }
        public var vertical   : Utils.UI.Layout.Anchor.Pair<NSLayoutYAxisAnchor, NSLayoutYAxisAnchor> { anchors.verticalAnchors }
        public var center     : Utils.UI.Layout.Anchor.Pair<NSLayoutXAxisAnchor, NSLayoutYAxisAnchor> { anchors.centerAnchors }
        public var size       : Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension> { anchors.sizeAnchors }
        public var edge       : Utils.UI.Layout.Anchor.Edges { anchors.edgeAnchors }
        
        public var safe: Self {
            .init(anchors.safeAnchors)
        }
    }
}
