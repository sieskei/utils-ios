//
//  UITextView+.swift
//  
//
//  Created by Miroslav Yozov on 4.03.20.
//

import UIKit

public extension UITextView {
    func setHTMLFromString(txt: String, font: UIFont, color: UIColor = .black, textAlignment: NSTextAlignment = .natural) {
        text = txt
        
        guard !text.isEmpty else {
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
        
        let source = style + text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let opts = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        if let data = source.data(using: String.Encoding.utf16, allowLossyConversion: true),
            let string = try? NSMutableAttributedString(data: data, options: opts, documentAttributes: nil) {
            attributedText = string.trimmed
        } else {
            attributedText = NSAttributedString(string: txt)
        }
    }
}
