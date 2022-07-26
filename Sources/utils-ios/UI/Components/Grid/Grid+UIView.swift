//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 25.07.22.
//

import UIKit

fileprivate var GridKey: UInt8 = 0

extension UIView {
    /// Grid reference.
    public var grid: Utils.UI.Grid {
        Utils.AssociatedObject.get(base: self, key: &GridKey) {
            .init(context: self)
        }
    }
  
    /// A reference to grid's layoutEdgeInsets.
    open var gridLayoutEdgeInsets: UIEdgeInsets {
        get {
            grid.layoutEdgeInsets
        }
        set {
            grid.layoutEdgeInsets = newValue
        }
    }
    
    /// A reference to grid's contentEdgeInsets.
    open var gridContentEdgeInsets: UIEdgeInsets {
        get {
            grid.contentEdgeInsets
        }
        set {
            grid.contentEdgeInsets = newValue
        }
    }
}
