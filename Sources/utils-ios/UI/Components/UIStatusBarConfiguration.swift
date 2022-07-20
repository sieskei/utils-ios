//
//  UIStatusBarConfiguration.swift
//  
//
//  Created by Miroslav Yozov on 26.10.20.
//

import UIKit

extension Utils.UI {
    public struct StatusBarConfiguration {
        public var style: UIStatusBarStyle = .default
        public var hidden: Bool = false
        public var updateAnimation: UIStatusBarAnimation = .fade
        public var isChildBased: Bool = false
        
        public init(style: UIStatusBarStyle = .default, hidden: Bool = false, updateAnimation: UIStatusBarAnimation = .fade, isChildBased: Bool = false) {
            self.style = style
            self.hidden = hidden
            self.updateAnimation = updateAnimation
            self.isChildBased = isChildBased
        }
    }
}
