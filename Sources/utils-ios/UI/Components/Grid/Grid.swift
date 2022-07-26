//
//  Grid.swift
//  
//
//  Created by Miroslav Yozov on 25.07.22.
//

import UIKit

extension Utils.UI {
    public class Grid {
        /// Context view.
        internal weak var context: UIView?
        
        /// Defer the calculation.
        public var isDeferred = false
        
        /// Number of rows.
        public var rows: Int {
            didSet {
                layout()
            }
        }
        
        /// Number of columns.
        public var columns: Int {
            didSet {
                layout()
            }
        }
        
        /// Offsets for rows and columns.
        public var offset: Offset = .init() {
            didSet {
                layout()
            }
        }
        
        /// The axis in which the Grid is laying out its views.
        public var axis: Axis = .init() {
            didSet {
                layout()
            }
        }
        
        /// The space between grid rows and columnss.
        public var interimSpace: CGFloat {
            didSet {
                layout()
            }
        }
        
        /// Insets value for grid.
        public var layoutEdgeInsets: UIEdgeInsets = .zero {
            didSet {
                layout()
            }
        }
        
        /// Insets value for grid.
        public var contentEdgeInsets: UIEdgeInsets = .zero {
            didSet {
                layout()
            }
        }
        
        /// An Array of UIButtons.
        public var views = [UIView]() {
            didSet {
                oldValue.forEach {
                    $0.removeFromSuperview()
                }
                layout()
            }
        }
        
        /**
         Initializer.
         - Parameter rows: The number of rows, vertical axis the grid will use.
         - Parameter columns: The number of columns, horizontal axis the grid will use.
         - Parameter interimSpace: The interim space between rows or columns.
         */
        internal init(context: UIView?, rows: Int = 0, columns: Int = 0, interimSpace: CGFloat = 0) {
          self.context = context
          self.rows = rows
          self.columns = columns
          self.interimSpace = interimSpace
        }
        
        /// Begins a deferred block.
        public func begin() {
            isDeferred = true
        }
        
        /// Completes a deferred block.
        public func commit() {
            isDeferred = false
            layout()
        }
        
        /**
         Update grid in a deferred block.
         - Parameter _ block: An update code block.
         */
        public func update(_ block: (Grid) -> Void) {
            begin()
            block(self)
            commit()
        }
        
        public func layout() {
            guard !isDeferred else {
                return
            }
            
            guard let canvas = context else {
                return
            }
            
            for v in views {
                if canvas != v.superview {
                    canvas.addSubview(v)
                }
            }
            
            let count = views.count
            
            guard 0 < count else {
                return
            }
            
            /// It is important to call `setNeedsLayout` and `layoutIfNeeded`
            /// in order to have the parent view's `frame` calculation be set
            /// for `Grid` to be able to then calculate the correct dimenions
            /// of its `child` views.
            canvas.setNeedsLayout()
            canvas.layoutIfNeeded()
            
            guard 0 < canvas.bounds.width && 0 < canvas.bounds.height else {
                return
            }
            
            var n = 0
            var i = 0
            
            for v in views {
                // Forces the view to adjust accordingly to size changes, ie: UILabel.
                (v as? UILabel)?.sizeToFit()

                switch axis.direction {
                case .horizontal:
                    let c = 0 == v.grid.columns ? axis.columns / count : v.grid.columns
                    let co = v.grid.offset.columns
                    let w = (canvas.bounds.width - contentEdgeInsets.left - contentEdgeInsets.right - layoutEdgeInsets.left - layoutEdgeInsets.right + interimSpace) / CGFloat(axis.columns)

                    v.frame.origin.x = CGFloat(i + n + co) * w + contentEdgeInsets.left + layoutEdgeInsets.left
                    v.frame.origin.y = contentEdgeInsets.top + layoutEdgeInsets.top
                    v.frame.size.width = w * CGFloat(c) - interimSpace
                    v.frame.size.height = canvas.bounds.height - contentEdgeInsets.top - contentEdgeInsets.bottom - layoutEdgeInsets.top - layoutEdgeInsets.bottom

                    n += c + co - 1
                case .vertical:
                    let r = 0 == v.grid.rows ? axis.rows / count : v.grid.rows
                    let ro = v.grid.offset.rows
                    let h = (canvas.bounds.height - contentEdgeInsets.top - contentEdgeInsets.bottom - layoutEdgeInsets.top - layoutEdgeInsets.bottom + interimSpace) / CGFloat(axis.rows)

                    v.frame.origin.x = contentEdgeInsets.left + layoutEdgeInsets.left
                    v.frame.origin.y = CGFloat(i + n + ro) * h + contentEdgeInsets.top + layoutEdgeInsets.top
                    v.frame.size.width = canvas.bounds.width - contentEdgeInsets.left - contentEdgeInsets.right - layoutEdgeInsets.left - layoutEdgeInsets.right
                    v.frame.size.height = h * CGFloat(r) - interimSpace

                    n += r + ro - 1
                case .any:
                    let r = 0 == v.grid.rows ? axis.rows / count : v.grid.rows
                    let ro = v.grid.offset.rows
                    let c = 0 == v.grid.columns ? axis.columns / count : v.grid.columns
                    let co = v.grid.offset.columns
                    let w = (canvas.bounds.width - contentEdgeInsets.left - contentEdgeInsets.right - layoutEdgeInsets.left - layoutEdgeInsets.right + interimSpace) / CGFloat(axis.columns)
                    let h = (canvas.bounds.height - contentEdgeInsets.top - contentEdgeInsets.bottom - layoutEdgeInsets.top - layoutEdgeInsets.bottom + interimSpace) / CGFloat(axis.rows)

                    v.frame.origin.x = CGFloat(co) * w + contentEdgeInsets.left + layoutEdgeInsets.left
                    v.frame.origin.y = CGFloat(ro) * h + contentEdgeInsets.top + layoutEdgeInsets.top
                    v.frame.size.width = w * CGFloat(c) - interimSpace
                    v.frame.size.height = h * CGFloat(r) - interimSpace
                }
              
                i += 1

                /// reload the grid layout for each view on
                /// each iteration, in order to ensure that
                /// subviews are recalculated correctly.
                if (isDeferred) { continue }
                v.grid.layout()
            }
        }
    }
}

extension Utils.UI.Grid {
    @objc(AxisDirection)
    public enum AxisDirection: Int {
      case any
      case horizontal
      case vertical
    }
}

extension Utils.UI.Grid {
    public struct Axis {
        /// The direction the grid lays its views out.
        public var direction = AxisDirection.horizontal

        /// The rows size.
        public var rows: Int

        /// The columns size.
        public var columns: Int

        /**
         Initializer.
         - Parameter rows: The number of rows, vertical axis the grid will use.
         - Parameter columns: The number of columns, horizontal axis the grid will use.
        */
        internal init(rows: Int = 12, columns: Int = 12) {
            self.rows = rows
            self.columns = columns
        }
    }
}

extension Utils.UI.Grid {
    public struct Offset {
        /// The rows size.
        public var rows: Int

        /// The columns size.
        public var columns: Int
      
        /**
         Initializer.
         - Parameter rows: The number of rows, vertical axis the grid will use.
         - Parameter columns: The number of columns, horizontal axis the grid will use.
        */
        internal init(rows: Int = 0, columns: Int = 0) {
            self.rows = rows
            self.columns = columns
        }
    }
}
