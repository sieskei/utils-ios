//
//  Foundation+.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

public extension String {
    var fromHTML: NSMutableAttributedString {
        guard let data = data(using: String.Encoding.utf16, allowLossyConversion: true) else {
            return NSMutableAttributedString()
        }
        
        let opts = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        return (try? NSMutableAttributedString(data: data, options: opts, documentAttributes: nil)) ?? NSMutableAttributedString()
    }
}

public extension Array {
    mutating func tryRemoveFirst() -> Element? {
        guard count > 0 else {
            return nil
        }
        return removeFirst()
    }
}

public extension Dictionary {
    func insert(value: Value, forKey key: Key) -> Dictionary<Key, Value> {
        var map = Dictionary<Key, Value>()
        map[key] = value
        forEach {
            map[$0] = $1
        }
        return map
    }
}

public extension Locale {
    static let Bulgaria: Locale? = Locale(identifier: "bg_BG")
}

public extension TimeZone {
    static var GMT: TimeZone? = TimeZone(secondsFromGMT: 0)
}
