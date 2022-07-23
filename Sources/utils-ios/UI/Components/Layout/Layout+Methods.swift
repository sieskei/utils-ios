//
//  Layout+Methods.swift
//  
//
//  Created by Miroslav Yozov on 22.07.22.
//

import UIKit

extension Utils.UI.Layout {
    /// A closure typealias for relation operators.
    public typealias RelationerType = (Void, Void) -> Utils.UI.Layout.Constraint.Builder
    
    /// A dummy struct used in creating relation operators (==, >=, <=).
    public struct Relationer {
        /**
         A method used as a default parameter for LayoutRelationer closures.
         Swift does not allow using == operator directly, so we had to create this.
        */
        public static func equality(lhs: Void, rhs: Void) -> Utils.UI.Layout.Constraint.Builder {
            .equality
        }
    }
    
    public struct Methods {
        let anchors: UtilsUIAnchorsCompatible
        init(_ a: UtilsUIAnchorsCompatible) {
            anchors = a
        }
        
        func expression<T: UtilsUILayoutAnchorType>(_ anchor: T? = nil,
                                                    _ path: KeyPath<UtilsUIAnchorsCompatible, T>,
                                                    _ constant: CGFloat = 0,
                                                    _ multiplier: CGFloat = 1.0,
                                                    _ priority: Utils.UI.Layout.Priority = .required,
                                                    _ safeArea: Bool = false) -> Utils.UI.Layout.Expression<T, CGFloat> {
            .init(anchor: anchor ?? anchors.unwrapParentAnchor(path, safe: safeArea),
                  constant: constant,
                  multiplier: multiplier,
                  priority: priority)
        }
    }
}

/// A method returning `Utils.UI.Layout.Constraint.Builder.equality`
public func ==(lhs: Void, rhs: Void) -> Utils.UI.Layout.Constraint.Builder {
    .equality
}

/// A method returning `Utils.UI.Layout.Constraint.Builder.greaterThanOrEqual`
public func >=(lhs: Void, rhs: Void) -> Utils.UI.Layout.Constraint.Builder {
    .greaterThanOrEqual
}

/// A method returning `Utils.UI.Layout.Constraint.Builder.lessThanOrEqual`
public func <=(lhs: Void, rhs: Void) -> Utils.UI.Layout.Constraint.Builder {
    .lessThanOrEqual
}

// MARK: - Edges
public extension Utils.UI.Layout.Methods {
    @discardableResult
    func top(anchor: NSLayoutYAxisAnchor? = nil,
             constant: CGFloat = 0,
             relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
             multiplier: CGFloat = 1.0,
             priority: Utils.UI.Layout.Priority = .required,
             safeArea: Bool = false) -> Utils.UI.Layout.Methods {
        let _ = relationer((), ()).topBuilder(anchors.topAnchor, expression(anchor, \.topAnchor, constant, multiplier, priority, safeArea))
        return self
    }
    
    @discardableResult
    func top(_ constant: CGFloat = 0,
             _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
             multiplier: CGFloat = 1.0,
             priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        top(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: false)
    }
    
    @discardableResult
    func topSafe(_ constant: CGFloat = 0,
                 _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                 multiplier: CGFloat = 1.0,
                 priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        top(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: true)
    }
    
    // ---
    
    @discardableResult
    func bottom(anchor: NSLayoutYAxisAnchor? = nil,
                constant: CGFloat = 0,
                relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                multiplier: CGFloat = 1.0,
                priority: Utils.UI.Layout.Priority = .required,
                safeArea: Bool = false) -> Utils.UI.Layout.Methods {
        let _ = relationer((), ()).bottomBuilder(anchors.bottomAnchor, expression(anchor, \.bottomAnchor, -constant, multiplier, priority, safeArea))
        return self
    }
    
    @discardableResult
    func bottom(_ constant: CGFloat = 0,
                _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                multiplier: CGFloat = 1.0,
                priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        bottom(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: false)
    }
    
    @discardableResult
    func bottomSafe(_ constant: CGFloat = 0,
                    _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                    multiplier: CGFloat = 1.0,
                    priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        bottom(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: true)
    }
    
    // ---
    
    @discardableResult
    func left(anchor: NSLayoutXAxisAnchor? = nil,
              constant: CGFloat = 0,
              relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
              multiplier: CGFloat = 1.0,
              priority: Utils.UI.Layout.Priority = .required,
              safeArea: Bool = false) -> Utils.UI.Layout.Methods {
        let _ = relationer((), ()).leadingBuilder(anchors.leftAnchor, expression(anchor, \.leftAnchor, constant, multiplier, priority, safeArea))
        return self
    }
    
    @discardableResult
    func left(_ constant: CGFloat = 0,
              _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
              multiplier: CGFloat = 1.0,
              priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        left(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: false)
    }
    
    @discardableResult
    func leftSafe(_ constant: CGFloat = 0,
                  _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                  multiplier: CGFloat = 1.0,
                  priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        left(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: true)
    }
    
    @discardableResult
    func after(_ anchors: UtilsUIAnchorsCompatible,
               _ constant: CGFloat = 0,
               _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
               multiplier: CGFloat = 1.0,
               priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        left(anchor: anchors.rightAnchor, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: false)
    }
    
    // ---
    
    @discardableResult
    func right(anchor: NSLayoutXAxisAnchor? = nil,
               constant: CGFloat = 0,
               relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
               multiplier: CGFloat = 1.0,
               priority: Utils.UI.Layout.Priority = .required,
               safeArea: Bool = false) -> Utils.UI.Layout.Methods {
        let _ = relationer((), ()).trailingBuilder(anchors.rightAnchor, expression(anchor, \.rightAnchor, -constant, multiplier, priority, safeArea))
        return self
    }
    
    @discardableResult
    func right(_ constant: CGFloat = 0,
               _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
               multiplier: CGFloat = 1.0,
               priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        right(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: false)
    }
    
    @discardableResult
    func rightSafe(_ constant: CGFloat = 0,
                   _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                   multiplier: CGFloat = 1.0,
                   priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        right(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: true)
    }
    
    @discardableResult
    func before(_ anchors: UtilsUIAnchorsCompatible,
                _ constant: CGFloat = 0,
                _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                multiplier: CGFloat = 1.0,
                priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        right(anchor: anchors.leftAnchor, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: false)
    }
    
    // ---
    
    @discardableResult
    func leading(anchor: NSLayoutXAxisAnchor? = nil,
                 constant: CGFloat = 0,
                 relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                 multiplier: CGFloat = 1.0,
                 priority: Utils.UI.Layout.Priority = .required,
                 safeArea: Bool = false) -> Utils.UI.Layout.Methods {
        let _ = relationer((), ()).leadingBuilder(anchors.leadingAnchor, expression(anchor, \.leadingAnchor, constant, multiplier, priority, safeArea))
        return self
    }
    
    @discardableResult
    func leading(_ constant: CGFloat = 0,
                 _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                 multiplier: CGFloat = 1.0,
                 priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        leading(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: false)
    }
    
    @discardableResult
    func leadingSafe(_ constant: CGFloat = 0,
                     _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                     multiplier: CGFloat = 1.0,
                     priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        leading(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: true)
    }
    
    // ---
    
    @discardableResult
    func trailing(anchor: NSLayoutXAxisAnchor? = nil,
                  constant: CGFloat = 0,
                  relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                  multiplier: CGFloat = 1.0,
                  priority: Utils.UI.Layout.Priority = .required,
                  safeArea: Bool = false) -> Utils.UI.Layout.Methods {
        let _ = relationer((), ()).trailingBuilder(anchors.trailingAnchor, expression(anchor, \.trailingAnchor, -constant, multiplier, priority, safeArea))
        return self
    }
    
    @discardableResult
    func trailing(_ constant: CGFloat = 0,
                  _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                  multiplier: CGFloat = 1.0,
                  priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        leading(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: false)
    }
    
    @discardableResult
    func trailingSafe(_ constant: CGFloat = 0,
                      _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                      multiplier: CGFloat = 1.0,
                      priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        leading(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: true)
    }
    
    // ---
    
    @discardableResult
    func edges(insets: UIEdgeInsets = .zero,
               priority: Utils.UI.Layout.Priority = .required,
               safeArea: Bool = false) -> Utils.UI.Layout.Methods {
        let parentAnchors = safeArea ? anchors.unwapParentAnchors.safeAnchors : anchors.unwapParentAnchors
        let _ = anchors.edgeAnchors.finalize(constraintsEqualToEdges: parentAnchors.edgeAnchors, insets: insets, priority: priority)
        return self
    }
    
    @discardableResult
    func edgesSafe(insets: UIEdgeInsets = .zero,
                   priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        edges(insets: insets, priority: priority, safeArea: true)
    }
}


// MARK: - Center
public extension Utils.UI.Layout.Methods {
    @discardableResult
    func centerY(anchor: NSLayoutYAxisAnchor? = nil,
                 constant: CGFloat = 0,
                 relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                 multiplier: CGFloat = 1.0,
                 priority: Utils.UI.Layout.Priority = .required,
                 safeArea: Bool = false) -> Utils.UI.Layout.Methods {
        let _ = relationer((), ()).centerYBuilder(anchors.centerYAnchor, expression(anchor, \.centerYAnchor, constant, multiplier, priority, safeArea))
        return self
    }
    
    @discardableResult
    func centerY(_ constant: CGFloat = 0,
                 _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                 multiplier: CGFloat = 1.0,
                 priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        centerY(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: false)
    }
    
    @discardableResult
    func centerYSafe(_ constant: CGFloat = 0,
                     _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                     multiplier: CGFloat = 1.0,
                     priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        centerY(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: true)
    }
    
    // ---
    
    @discardableResult
    func centerX(anchor: NSLayoutXAxisAnchor? = nil,
                 constant: CGFloat = 0,
                 relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                 multiplier: CGFloat = 1.0,
                 priority: Utils.UI.Layout.Priority = .required,
                 safeArea: Bool = false) -> Utils.UI.Layout.Methods {
        let _ = relationer((), ()).centerXBuilder(anchors.centerXAnchor, expression(anchor, \.centerXAnchor, constant, multiplier, priority, safeArea))
        return self
    }
    
    @discardableResult
    func centerX(_ constant: CGFloat = 0,
                 _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                 multiplier: CGFloat = 1.0,
                 priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        centerX(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: false)
    }
    
    @discardableResult
    func centerXSafe(_ constant: CGFloat = 0,
                     _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                     multiplier: CGFloat = 1.0,
                     priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        centerX(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: true)
    }
}


// MARK: - Dimensions
public extension Utils.UI.Layout.Methods {
    @discardableResult
    func width(anchor: NSLayoutDimension? = nil,
               constant: CGFloat = 0,
               relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
               multiplier: CGFloat = 1.0,
               priority: Utils.UI.Layout.Priority = .required,
               safeArea: Bool = false) -> Utils.UI.Layout.Methods {
        let _ = relationer((), ()).dimensionBuilder(anchors.widthAnchor, expression(anchor, \.widthAnchor, constant, multiplier, priority, safeArea))
        return self
    }
    
    @discardableResult
    func width(_ constant: CGFloat = 0,
               _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
               multiplier: CGFloat = 1.0,
               priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        let _ = relationer((), ()).dimensionBuilder(anchors.widthAnchor, .init(constant: constant, multiplier: multiplier, priority: priority))
        return self
    }
    
    @discardableResult
    func widthSuper(_ constant: CGFloat = 0,
                    _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                    multiplier: CGFloat = 1.0,
                    priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        width(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: false)
    }
    
    @discardableResult
    func widthSafe(_ constant: CGFloat = 0,
                   _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                   multiplier: CGFloat = 1.0,
                   priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        width(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: true)
    }
    
    // ---
    
    @discardableResult
    func height(anchor: NSLayoutDimension? = nil,
                constant: CGFloat = 0,
                relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                multiplier: CGFloat = 1.0,
                priority: Utils.UI.Layout.Priority = .required,
                safeArea: Bool = false) -> Utils.UI.Layout.Methods {
        let _ = relationer((), ()).dimensionBuilder(anchors.heightAnchor, expression(anchor, \.heightAnchor, constant, multiplier, priority, safeArea))
        return self
    }
    
    @discardableResult
    func height(_ constant: CGFloat = 0,
                _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                multiplier: CGFloat = 1.0,
                priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        let _ = relationer((), ()).dimensionBuilder(anchors.heightAnchor, .init(constant: constant, multiplier: multiplier, priority: priority))
        return self
    }
    
    @discardableResult
    func heightSuper(_ constant: CGFloat = 0,
                     _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                     multiplier: CGFloat = 1.0,
                     priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        height(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: false)
    }
    
    @discardableResult
    func heightSafe(_ constant: CGFloat = 0,
                    _ relationer: Utils.UI.Layout.RelationerType = Utils.UI.Layout.Relationer.equality,
                    multiplier: CGFloat = 1.0,
                    priority: Utils.UI.Layout.Priority = .required) -> Utils.UI.Layout.Methods {
        height(anchor: nil, constant: constant, relationer: relationer, multiplier: multiplier, priority: priority, safeArea: true)
    }
}
