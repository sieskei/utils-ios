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
    struct Configuration {
        public static var group = "group.bg.netinfo"
        public static var prefix = ""
        
        fileprivate static func gen(_ key: String) -> String {
            "\(prefix.isEmpty ? Bundle.main.bundleIdentifier ?? "" : prefix).\(key)".replacingOccurrences(of: ".", with: ":")
            // "\(prefix.isEmpty ? Bundle.main.bundleIdentifier ?? "" : prefix).\(key)"
        }
    }
    
    fileprivate static let defaults: UserDefaults = {
        guard !Configuration.group.isEmpty else {
            return .standard
        }
        return UserDefaults(suiteName: Configuration.group) ?? .standard
    }()
}

public extension Utils.Storage {
    static func get<T: PrimitiveType>(for key: String, default: () -> T) -> T {
        if let value = defaults.object(forKey: Configuration.gen(key)) as? T {
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
        defaults.set(value, forKey: Configuration.gen(key))
    }
    
    static func get<T: RawRepresentable>(for key: String, default: T) -> T where T.RawValue: PrimitiveType {
        let raw: T.RawValue = get(for: key) { `default`.rawValue }
        return T(rawValue: raw) ?? `default`
    }
    
    static func set<T: RawRepresentable>(key: String, value: T) where T.RawValue: PrimitiveType {
        defaults.set(value.rawValue, forKey: Configuration.gen(key))
    }
    
    static func get<T: Codable>(for key: String, default: T) -> T {
        guard let data = defaults.data(forKey: Configuration.gen(key)),
              let value = try? JSONDecoder().decode(T.self, from: data) else {
            set(key: key, value: `default`)
            return `default`
        }
        
        return value
    }
    
    static func set<T: Encodable>(key: String, value: T) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: Configuration.gen(key))
        }
    }
    
    static func remove(key: String) {
        defaults.removeObject(forKey: Configuration.gen(key))
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
        guard let data = defaults.data(forKey: Configuration.gen(key)),
              let pair = try? JSONDecoder().decode(Pair<C, V>.self, from: data) else {
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
            defaults.set(data, forKey: Configuration.gen(key))
        }
    }
}

extension Utils.Storage: ReactiveCompatible { }

public extension Reactive where Base == Utils.Storage {
    static func get<T: PrimitiveType>(for key: String, default: T) -> Observable<T> {
        Base.defaults.rx.observe(T.self, Base.Configuration.gen(key)).map { $0 ?? `default` }
    }
}

//extension Utils.Storage {
//    @propertyWrapper
//    public struct RawProperty<T: RawRepresentable>: RxNonEquatableProperty where T.RawValue: PrimitiveType {
//        public let key: String
//        public let `default`: T
//        
//        public var wrappedValue: T {
//            get { Utils.Storage.get(for: key, default: `default`) }
//            set { Utils.Storage.set(key: key, value: newValue) }
//        }
//        
//        public init(wrappedValue: T, key k: String) {
//            key = k
//            `default` = wrappedValue
//        }
//    }
//}



