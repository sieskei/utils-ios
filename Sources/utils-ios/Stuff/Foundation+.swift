//
//  Foundation+.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

extension Array {
    mutating func tryRemoveFirst() -> Element? {
        guard count > 0 else {
            return nil
        }
        return removeFirst()
    }
}

extension Dictionary {
    func insert(value: Value, forKey key: Key) -> Dictionary<Key, Value> {
        var map = Dictionary<Key, Value>()
        map[key] = value
        forEach {
            map[$0] = $1
        }
        return map
    }
}

extension Locale {
    static let Bulgaria: Locale? = Locale(identifier: "bg_BG")
}

extension TimeZone {
    static var GMT: TimeZone? = TimeZone(secondsFromGMT: 0)
}
