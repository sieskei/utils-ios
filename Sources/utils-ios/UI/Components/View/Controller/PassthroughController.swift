//
//  PassthroughController.swift
//  
//
//  Created by Miroslav Yozov on 20.07.22.
//

import UIKit

extension Utils.UI {
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
