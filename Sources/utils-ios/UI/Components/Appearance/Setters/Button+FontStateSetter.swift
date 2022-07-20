//
//  Button+FontStateSetter.swift
//  
//
//  Created by Miroslav Yozov on 20.07.22.
//

import UIKit

extension Utils.UI.Button {
    public override func set(fontColor color: UIColor) {
        self.titleColor = color
    }

    public override func set(fontColor color: UIColor, for state: UIControl.State) {
        switch state {
        case .normal:
            self.titleColor = color
        case .selected:
            self.selectedTitleColor = color
        default:
            super.set(fontColor: color, for: state)
        }
    }
}
