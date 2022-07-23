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
    }
}
