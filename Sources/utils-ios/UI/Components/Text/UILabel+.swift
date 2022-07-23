//
//  UILabel+.swift
//  
//
//  Created by Miroslav Yozov on 13.01.20.
//

import UIKit

public extension UILabel {
    /// Convenience way to change font size.
    var fontSize: CGFloat {
        get {
            return font?.pointSize ?? UIFont.labelFontSize
        }
        set(value) {
            font = font?.withSize(value) ?? UIFont.systemFont(ofSize: value)
        }
    }
    
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
        
        if let data = source.data(using: String.Encoding.utf16),
           let at = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            attributedText = at
        } else {
            attributedText = NSAttributedString(string: source)
        }
    }
    
    func setHTMLFromString(txt: String, font: UIFont, color: UIColor = .black, textAlignment: NSTextAlignment = .natural) {
        text = txt
        
        guard !txt.isEmpty else {
            attributedText = nil
            return
        }
        
        let style =
        """
            <style>
                html {
                    font-family: \(font.fontName);
                    font-size: \(font.pointSize);
                    color: \(color.hexString(.RRGGBB));
                    text-align: \(textAlignment.description);
                }
            </style>
        """
        
        let source = style + txt.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let opts = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        if let data = source.data(using: String.Encoding.utf16, allowLossyConversion: true),
            let string = try? NSMutableAttributedString(data: data, options: opts, documentAttributes: nil) {
            attributedText = string.trimmed
        } else {
            attributedText = NSAttributedString(string: txt)
        }
    }
}
