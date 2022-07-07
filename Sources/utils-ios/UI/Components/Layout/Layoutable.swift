//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 6.07.22.
//

import UIKit

public protocol UtilsUILayoutable: AnyObject {
    var layout: Utils.UI.Layout { get }
}

extension UIView: UtilsUILayoutable {
    public var layout: Utils.UI.Layout {
        .init(self)
    }
}
