//
//  UIAppearance+.swift
//  
//
//  Created by Miroslav Yozov on 18.01.20.
//

import UIKit

public extension UIAppearance {
    static func appearance(_ modificator: (Self) -> Void) {
        modificator(appearance())
    }
    
    static func appearance(in containerTypes: [UIAppearanceContainer.Type], _ modificator: (Self) -> Void) {
        modificator(appearance(whenContainedInInstancesOf: containerTypes))
    }
    
    static func appearance(for trait: UITraitCollection, _ modificator: (Self) -> Void) {
        modificator(appearance(for: trait))
    }
}
