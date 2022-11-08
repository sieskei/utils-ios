//
//  CartView.swift
//  
//
//  Created by Miroslav Yozov on 8.11.22.
//

import Foundation

extension Utils.UI.View {
    open class Cart: Utils.UI.View {
        open var cornerRaduis: CGFloat = Utils.UI.CornerRadiusPreset.cornerRadius2.value {
            didSet {
                prepareRadius()
            }
        }
        
        open var depth: Utils.UI.Depth.Preset = .square(.depth3) {
            didSet {
                prepareShadow()
            }
        }
        
        public let contentView: Utils.UI.View = .init()
        
        open override func prepare() {
            super.prepare()
            
            layout(contentView)
                .edges()
            
            prepareRadius()
            prepareShadow()
        }
        
        private func prepareRadius() {
            set(cornerRadius: cornerRaduis); layer.masksToBounds = false // need to be revert for shadow
            contentView.set(cornerRadius: cornerRaduis)
        }
        
        private func prepareShadow() {
            set(depth: depth)
        }
    }
}
