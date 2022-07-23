//
//  Layout.swift
//
//
//  Created by Miroslav Yozov on 7.07.22.
//

import UIKit

// MARK: - namespaces
extension Utils.UI {
    public struct Layout {
        /**
         Constraint Activation.
         */
        @discardableResult
        static func finalize(constraint: NSLayoutConstraint, withPriority priority: Utils.UI.Layout.Priority = .required) -> NSLayoutConstraint {
            // Only disable autoresizing constraints on the LHS item, which is the one definitely intended to be governed by Auto Layout
            if let first = constraint.firstItem as? UIView {
                first.translatesAutoresizingMaskIntoConstraints = false
            }

            constraint.priority = priority.value

            if let lastBatch = Constraint.Batch.instances.last {
                lastBatch.add(constraint: constraint)
            } else {
                constraint.isActive = true
            }
            
            return constraint
        }
        
        // MARK: - Batching

        /// Any Anchorage constraints created inside the passed closure are returned in the array.
        ///
        /// - Parameter closure: A closure that runs some Anchorage expressions.
        /// - Returns: An array of new, active `NSLayoutConstraint`s.
        @discardableResult
        public static func batch(_ closure: () -> Void) -> [NSLayoutConstraint] {
             batch(active: true, closure: closure)
        }

        /// Any Anchorage constraints created inside the passed closure are returned in the array.
        ///
        /// - Parameter active: Whether the created constraints should be active when they are returned.
        /// - Parameter closure: A closure that runs some Anchorage expressions.
        /// - Returns: An array of new `NSLayoutConstraint`s.
        static func batch(active: Bool, closure: () -> Void) -> [NSLayoutConstraint] {
            let batch: Constraint.Batch = .init()
            Constraint.Batch.instances.append(batch)
            defer {
                Constraint.Batch.instances.removeLast()
            }
        
            closure()
        
            if active {
                batch.activate()
            }
        
            return batch.constraints
        }
        
        static func performInBatch(closure: () -> Void) {
            if Constraint.Batch.instances.isEmpty {
                batch(closure)
            } else {
                closure()
            }
        }
    }
}

extension UIView {
    public var layout_: Utils.UI.Layout.Methods {
        .init(self)
    }
}
