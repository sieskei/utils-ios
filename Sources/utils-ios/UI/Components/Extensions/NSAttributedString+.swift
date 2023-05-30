//
//  NSAttributedString+ul.swift
//  
//
//  Created by Miroslav Yozov on 30.05.23.
//

import UIKit

public extension NSAttributedString {
    static func ul(from strings: [String],
                   bulletCharacter: String = "⦿",
                   bulletAttributes: [NSAttributedString.Key: Any] = [:],
                   textAttributes: [NSAttributedString.Key: Any] = [:],
                   indentation: CGFloat = 16,
                   lineSpacing: CGFloat = 1,
                   paragraphSpacing: CGFloat = 8) -> NSAttributedString {
        let paragraphStyle: NSMutableParagraphStyle = .init() ~> {
            $0.defaultTabInterval = indentation
            $0.tabStops = [.init(textAlignment: .left, location: indentation)]
            $0.lineSpacing = lineSpacing
            $0.paragraphSpacing = paragraphSpacing
            $0.headIndent = indentation
        }
        
        let list: NSMutableAttributedString = .init()
        
        strings.forEach {
            let item = "\(bulletCharacter)\t\($0)\n"

            var attributes = textAttributes
            attributes[.paragraphStyle] = paragraphStyle

            let attributedString = NSMutableAttributedString(string: item, attributes: attributes)

            if !bulletAttributes.isEmpty {
                let bulletRange = (item as NSString).range(of: bulletCharacter)
                attributedString.addAttributes(bulletAttributes, range: bulletRange)
            }

            list.append(attributedString)
        }
        
        if list.string.hasSuffix("\n") {
            list.deleteCharacters(
                in: NSRange(location: list.length - 1, length: 1)
            )
        }

        return list
    }
    
    var range: NSRange {
        .init(location: 0, length: length)
    }
}
