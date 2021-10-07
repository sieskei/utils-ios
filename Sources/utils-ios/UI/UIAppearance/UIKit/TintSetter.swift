//
//  TintSetter.swift
//  
//
//  Created by Miroslav Yozov on 22.01.20.
//

import UIKit

@objc
public protocol TintSetter {
    dynamic func set(tintColor color: UIColor)
}

extension UIView: TintSetter {
    public func set(tintColor color: UIColor) {
        self.tintColor = color
    }
}


@objc
public protocol TrackTintSetter {
    dynamic func set(trackTintColor color: UIColor)
}

extension UIProgressView: TrackTintSetter {
    public func set(trackTintColor color: UIColor) {
        self.trackTintColor = color
    }
}
