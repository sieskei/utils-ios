//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 20.07.22.
//

import Foundation
import UIKit

extension Utils.UI.Button {
    public class func icon(_ image: UIImage?, tintColor color: UIColor? = nil) -> Utils.UI.Button {
        .init(image: image, tintColor: color) ~> {
            $0.pulseType = .center
        }
    }
}
