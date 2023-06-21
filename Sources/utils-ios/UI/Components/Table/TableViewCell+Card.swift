//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 8.11.22.
//

import UIKit

extension Utils.UI.TableViewCell {
    open class Card: Utils.UI.TableViewCell {
        // TODO: Insets
        public private (set) lazy var cartView: Utils.UI.View.Cart = .init()
        
        open override func prepare() {
            super.prepare()
            prepareCartView()
        }
    }
}

extension Utils.UI.TableViewCell.Card {
    override func insert(pulseContainer layer: CALayer) {
        cartView.layer
            .addSublayer(layer)
    }

    override func layout(pulseContainer layer: CALayer) {
        layer.frame = cartView.bounds
        layer.cornerRadius = cartView.layer.cornerRadius
    }
}

extension Utils.UI.TableViewCell.Card {
    @objc
    open dynamic func prepareCartView() {
        contentView.layout(cartView)
            .edgesSafe(insets: .init(top: 16, left: 16, bottom: .zero, right: 16))
    }
}
