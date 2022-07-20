//
//  PassthroughView.swift
//  
//
//  Created by Miroslav Yozov on 20.07.22.
//

import UIKit

extension Utils.UI {
    open class PassthroughView: Utils.UI.View {
        override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            let view = super.hitTest(point, with: event)
            return view == self ? nil : view
        }
    }
}
