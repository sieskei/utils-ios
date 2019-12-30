//
//  PassthroughView.swift
//  
//
//  Created by Miroslav Yozov on 30.12.19.
//

import UIKit

public class PassthroughView: UIView {
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}
