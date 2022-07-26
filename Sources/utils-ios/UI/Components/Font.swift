//
//  Font.swift
//  
//
//  Created by Miroslav Yozov on 25.07.22.
//

import UIKit

extension Utils.UI {
    public struct Font {
        /// Size of font.
        public static let pointSize: CGFloat = 16

        /**
        Retrieves the system font with a specified size.
        - Parameter ofSize size: A CGFloat.
        */
        public static func systemFont(ofSize size: CGFloat = pointSize) -> UIFont {
            UIFont.systemFont(ofSize: size)
        }

        /**
        Retrieves the bold system font with a specified size..
        - Parameter ofSize size: A CGFloat.
        */
        public static func boldSystemFont(ofSize size: CGFloat = pointSize) -> UIFont {
            UIFont.boldSystemFont(ofSize: size)
        }

        /**
        Retrieves the italic system font with a specified size.
        - Parameter ofSize size: A CGFloat.
        */
        public static func italicSystemFont(ofSize size: CGFloat = pointSize) -> UIFont {
            UIFont.italicSystemFont(ofSize: size)
        }
    }
}
