//
//  UILabel+.swift
//  
//
//  Created by Miroslav Yozov on 13.01.20.
//

import UIKit

public extension UILabel {
    func setHTMLFromString(text: String) {
        guard !text.isEmpty else {
            attributedText = nil
            return
        }
        
        let source: String
        if let font = font {
            let color = textColor?.hexString(.RRGGBB) ?? "#000000"
            source =
            """
            <span style=\"display: block; font-family: '\(font.fontName)'; font-size: \(font.pointSize)px; color: \(color); text-align: \(textAlignment.description);\">\(text.trimmingCharacters(in: .whitespacesAndNewlines))</span>
            """
        } else {
            source = text
        }
        
        if let data = source.data(using: String.Encoding.utf16, allowLossyConversion: true) {
            let at = NSMutableAttributedString()
            try? at.read(from: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
            attributedText = at.trimmed
        } else {
            attributedText = NSAttributedString(string: source)
        }
    }
}
