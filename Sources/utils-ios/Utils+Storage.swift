//
//  Utils+Storage.swift
//  
//
//  Created by Miroslav Yozov on 21.02.20.
//

import Foundation
import RxSwift

public extension Utils {
    class Storage { }
}

public extension Utils.Storage {
    struct Keys {
        public static var group = "group.bg.netinfo"
        
        fileprivate static func gen(_ key: String) -> String {
            guard let identifier = Bundle.main.bundleIdentifier else {
                return key
            }
            return "\(identifier).\(key)".replacingOccurrences(of: ".", with: ":")
        }
    }
    
    fileprivate static let defaults = UserDefaults(suiteName: Keys.group) ?? .standard
}

public extension Utils.Storage {
    static func get<T: PrimitiveType>(for key: String, default: () -> T) -> T {
        if let value = defaults.object(forKey: Keys.gen(key)) as? T {
            return value
        } else {
            let v = `default`()
            set(key: key, value: v)
            return v
        }
    }
    
    static func get<T: PrimitiveType>(for key: String, default: T) -> T {
        get(for: key) { `default` }
    }
    
    static func set(key: String, value: PrimitiveType) {
        defaults.set(value, forKey: Keys.gen(key))
    }
    
    static func get<T: Codable>(for key: String, default: T) -> T {
        guard let data = defaults.data(forKey: Keys.gen(key)) else {
            set(key: key, value: `default`)
            return `default`
        }
        
        guard let value = try? JSONDecoder().decode(T.self, from: data) else {
            set(key: key, value: `default`)
            return `default`
        }
        
        return value
    }
    
    static func set<T: Encodable>(key: String, value: T) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: Keys.gen(key))
        }
    }
    
    static func remove(key: String) {
        defaults.removeObject(forKey: Keys.gen(key))
    }
}

public extension Utils.Storage {
    typealias ControlType = PrimitiveType & Equatable & Codable
    typealias ValueType = PrimitiveType & Codable
    
    private struct Pair<C: ControlType, V: ValueType>: Codable {
        let control: C
        let value: V
    }
    
    static func get<C: ControlType, V: ValueType>(for key: String, control: C, `default`: V) -> V {
        guard let data = defaults.data(forKey: Keys.gen(key)) else {
            set(key: key, control: control, value: `default`)
            return `default`
        }
        
        guard let pair = try? JSONDecoder().decode(Pair<C, V>.self, from: data) else {
            set(key: key, control: control, value: `default`)
            return `default`
        }
        
        if pair.control == control {
            return pair.value
        } else {
            set(key: key, control: control, value: `default`)
            return `default`
        }
    }
    
    static func set<C: ControlType, V: ValueType>(key: String, control: C, value: V) {
        let pair = Pair(control: control, value: value)
        if let data = try? JSONEncoder().encode(pair) {
            defaults.set(data, forKey: Keys.gen(key))
        }
    }
}

extension Utils.Storage: ReactiveCompatible { }

public extension Reactive where Base == Utils.Storage {
    static func get<T: PrimitiveType>(for key: String, default: T) -> Observable<T> {
        Base.defaults.rx.observe(T.self, Base.Keys.gen(key)).map { $0 ?? `default` }
    }
}


