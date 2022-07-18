//
//  PulseSetter.swift
//  
//
//  Created by Miroslav Yozov on 22.01.20.
//

import UIKit
import Material

@objc
public protocol PulseSetter {
    dynamic func set(pulseOpacity opacity: CGFloat)
    dynamic func set(pulseAnimation animation: PulseAnimation)
    dynamic func set(pulseColor color: UIColor)
}

extension Button: PulseSetter {
    public func set(pulseOpacity opacity: CGFloat) {
        self.pulseOpacity = opacity
    }
    
    public func set(pulseAnimation animation: PulseAnimation) {
        self.pulseAnimation = animation
    }
    
    public func set(pulseColor color: UIColor) {
        self.pulseColor = color
    }
}

extension TableViewCell: PulseSetter {
    public func set(pulseOpacity opacity: CGFloat) {
        self.pulseOpacity = opacity
    }
    
    public func set(pulseAnimation animation: PulseAnimation) {
        self.pulseAnimation = animation
    }
    
    public func set(pulseColor color: UIColor) {
        self.pulseColor = color
    }
}

extension CollectionViewCell: PulseSetter {
    public func set(pulseOpacity opacity: CGFloat) {
        self.pulseOpacity = opacity
    }
    
    public func set(pulseAnimation animation: PulseAnimation) {
        self.pulseAnimation = animation
    }
    
    public func set(pulseColor color: UIColor) {
        self.pulseColor = color
    }
}
