//
//  VisualEffectView+Rx.swift
//  sinoptik-ios
//
//  Created by Miroslav Yozov on 7.06.19.
//  Copyright © 2019 Net Info. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

extension Reactive where Base: Utils.UI.VisualEffectView {
    /// Bindable sink for `colorTint` property.
    var colorTint: Binder<UIColor?> {
        return Binder(self.base) { view, color in
            view.colorTint = color
        }
    }
    
    /// Bindable sink for `colorTintAlpha` property.
    var colorTintAlpha: Binder<CGFloat> {
        return Binder(self.base) { view, alpha in
            view.colorTintAlpha = alpha
        }
    }
    
    /// Bindable sink for `blurRadius` property.
    var blurRadius: Binder<CGFloat> {
        return Binder(self.base) { view, radius in
            view.blurRadius = radius
        }
    }
}
