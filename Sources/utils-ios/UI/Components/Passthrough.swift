//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 7.04.22.
//

import UIKit

extension Utils.UI {
    open class PassthroughWindow: Utils.UI.Window {
        public final var controller: PassthroughController {
            Utils.castOrFatalError(rootViewController)
        }
        
        public final var view: PassthroughView {
            Utils.castOrFatalError(controller.view)
        }
        
        public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            let view = super.hitTest(point, with: event)
            return view == self ? nil : view
        }
        
        open override func prepare() {
            super.prepare()
            backgroundColor = .clear
            rootViewController = PassthroughController()
        }
    }
    
    open class PassthroughView: Utils.UI.View {
        override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            let view = super.hitTest(point, with: event)
            return view == self ? nil : view
        }
    }
    
    open class PassthroughController: Utils.UI.ViewController {
        public override func prepare() {
            super.prepare()
            view.backgroundColor = .clear
        }
        
        public override func loadView() {
            view = PassthroughView()
        }
    }
}
