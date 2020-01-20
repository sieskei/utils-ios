//
//  UIImageView+Rx.swift
//  utils-ios
//
//  Created by Miroslav Yozov on 28.11.19.
//

import UIKit

import RxSwift
import RxCocoa

import AlamofireImage

public extension Reactive where Base: UIImageView {
    /// Bindable sink for `barTintColor` property.
    var imageURL: Binder<URL?> {
        return Binder(self.base) { view, url in
            if let url = url {
                view.af_setImage(withURL: url)
            } else {
                view.image = nil
            }
        }
    }
    
    var transitionImageURL: Binder<(URL?, UIImageView.ImageTransition)> {
        return Binder(self.base) { view, pair in
            if let url = pair.0 {
                view.af_setImage(withURL: url, imageTransition: pair.1)
            } else {
                view.image = nil
            }
        }
    }
}
