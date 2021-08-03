//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 23.07.21.
//

import UIKit

public extension NSLayoutConstraint {
    func activate() -> Self {
        isActive = true
        return self
    }
}
