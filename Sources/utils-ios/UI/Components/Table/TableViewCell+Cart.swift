//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 8.11.22.
//

import UIKit

extension Utils.UI.TableViewCell {
    open class Cart: Utils.UI.TableViewCell {
        // TODO: Insets
        public private (set) lazy var cartView: Utils.UI.View.Cart = .init()
        
        open override func prepare() {
            super.prepare()
            
            contentView.layout(cartView)
                .edgesSafe(insets: .init(top: 16, left: 16, bottom: .zero, right: 16))
        }
    }
}

extension Utils.UI.TableViewCell.Cart {
    override func insert(pulseContainer layer: CALayer) {
        cartView.layer
            .addSublayer(layer)
    }

    override func layout(pulseContainer layer: CALayer) {
        layer.frame = cartView.bounds
        layer.cornerRadius = cartView.layer.cornerRadius
    }
}
