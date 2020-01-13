//
//  UILabel+.swift
//  
//
//  Created by Miroslav Yozov on 13.01.20.
//

import UIKit

public extension UILabel {
    func setHTMLFromString(text: String) {
        let source: String
        if let font = font {
            let color = textColor?.hexString(.RRGGBB) ?? "#000000"
            source = "<span style=\"font-family: \(font.fontName); font-size: \(font.pointSize); color: \(color); \">\(text)</span>"
        } else {
            source = text
        }
        
        let opts = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        if let data = source.data(using: String.Encoding.utf16, allowLossyConversion: true),
            let string = try? NSMutableAttributedString(data: data, options: opts, documentAttributes: nil) {
                attributedText = string
        } else {
            attributedText = NSAttributedString(string: source)
        }
    }
}
