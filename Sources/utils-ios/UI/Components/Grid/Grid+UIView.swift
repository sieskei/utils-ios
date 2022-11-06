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
    
    /// A reference to grid's interimSpace.
    public var gridUnterimSpace: CGFloat {
        get {
            grid.interimSpace
        }
        set {
            grid.interimSpace = newValue
        }
    }
  
    /// A reference to grid's layoutEdgeInsets.
    public var gridLayoutEdgeInsets: UIEdgeInsets {
        get {
            grid.layoutEdgeInsets
        }
        set {
            grid.layoutEdgeInsets = newValue
        }
    }
    
    /// A reference to grid's contentEdgeInsets.
    public var gridContentEdgeInsets: UIEdgeInsets {
        get {
            grid.contentEdgeInsets
        }
        set {
            grid.contentEdgeInsets = newValue
        }
    }
}
