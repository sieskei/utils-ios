//
//  Icon.swift
//  
//
//  Created by Miroslav Yozov on 22.07.22.
//

import UIKit

extension Utils.UI {
    public struct Icon {
        public static func icon(named name: String, renderingMode mode: UIImage.RenderingMode = .alwaysOriginal) -> UIImage? {
            .init(named: name)?.withRenderingMode(mode)
        }
        
        public static let visibility = Icon.icon(named: "ic_visibility_white")
        public static let visibilityOff = Icon.icon(named: "ic_visibility_off_white")
        public static let clear = Icon.icon(named: "ic_close_white")
    }
}
