//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 7.09.20.
//

import UIKit
import Material

extension TabItem {
    public override func set(fontColor color: UIColor, for state: UIControl.State) {
        switch state {
        case .normal:
            setTabItemColor(color, for: .normal)
        case .highlighted:
            setTabItemColor(color, for: .highlighted)
        case .selected:
            setTabItemColor(color, for: .selected)
        default:
            super.set(fontColor: color, for: state)
        }
    }
}
