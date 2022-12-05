//
//  PassthroughWindow.swift
//  
//
//  Created by Miroslav Yozov on 20.07.22.
//

import UIKit

extension Utils.UI {
    open class PassthroughWindow: Utils.UI.Window {
        open var initRootViewController: PassthroughController {
            .init()
        }
        
        public final var controller: PassthroughController {
            Utils.castOrFatalError(rootViewController)
        }
        
        public final var view: PassthroughView {
            Utils.castOrFatalError(controller.view)
        }
        
        open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            let view = view.hitTest(point, with: event) //Skip views between Window and Root 
            return view == self ? nil : view
        }
        
        open override func prepare() {
            super.prepare()
            backgroundColor = .clear
            rootViewController = initRootViewController
        }
    }
}
