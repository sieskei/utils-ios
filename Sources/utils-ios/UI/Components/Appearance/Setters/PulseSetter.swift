//
//  PulseSetter.swift
//  
//
//  Created by Miroslav Yozov on 20.07.22.
//

import UIKit

@objc
public protocol UtilsUIPulseSetter {
    dynamic func set(pulseType type: Utils.UI.Pulse.`Type`)
    dynamic func set(pulseOpacity opacity: CGFloat, color: UIColor)
}

extension Utils.UI.Button: UtilsUIPulseSetter {
    public func set(pulseType type: Utils.UI.Pulse.`Type`) {
        self.pulseType = type
    }
    
    public func set(pulseOpacity opacity: CGFloat, color: UIColor) {
        self.pulseStyle = .init(opacity: opacity, color: color)
    }
}

extension Utils.UI.TableViewCell: UtilsUIPulseSetter {
    public func set(pulseType type: Utils.UI.Pulse.`Type`) {
        self.pulseType = type
    }
    
    public func set(pulseOpacity opacity: CGFloat, color: UIColor) {
        self.pulseStyle = .init(opacity: opacity, color: color)
    }
}
