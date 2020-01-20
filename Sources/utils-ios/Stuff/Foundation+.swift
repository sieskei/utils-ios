//
//  Foundation+.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

public extension NSMutableAttributedString {
    var trimmed: NSAttributedString {
        let invertedSet = CharacterSet.whitespacesAndNewlines.inverted
        let startRange = string.rangeOfCharacter(from: invertedSet)
        let endRange = string.rangeOfCharacter(from: invertedSet, options: .backwards)
        guard let startLocation = startRange?.upperBound, let endLocation = endRange?.lowerBound else {
            return NSAttributedString(string: string)
        }
        let location = string.distance(from: string.startIndex, to: startLocation) - 1
        let length = string.distance(from: startLocation, to: endLocation) + 2
        let range = NSRange(location: location, length: length)
        
        return attributedSubstring(from: range)
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
