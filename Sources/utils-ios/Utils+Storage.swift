//
//  Utils+Storage.swift
//  
//
//  Created by Miroslav Yozov on 21.02.20.
//

import Foundation

extension Utils {
    class Storage {
        struct Keys {
            static let group = "group.bg.netinfo"
        }
        
        fileprivate static let defaults = UserDefaults(suiteName: Keys.group)!
        
        static func get<T>(for key: String, default: T) -> T {
            if let value = defaults.object(forKey: "\(key)") as? T {
                return value
            } else {
                set(key: key, value: `default`)
                return `default`
            }
        }
        
        static func set<T>(key: String, value: T) {
            defaults.set(value, forKey: key)
            // defaults.set
        }
        
        static func map<R, T>(key: String, default: T, transform: (T) -> R) -> R {
            return transform(get(for: key, default: `default`))
        }
    }
}
