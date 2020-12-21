//
//  OrderedDictionary.swift
//  
//
//  Created by Miroslav Yozov on 21.12.20.
//

import Foundation

public class OrderedDictionary<K: Hashable, V> {
    private var key2value: [K: V] = [:]
    
    public private (set) var keys: [K] = []
    
    public var values: [V] {
        .init(key2value.values)
    }
    
    public var count: Int {
        assert(keys.count == key2value.count, "Keys and values array out of sync.")
        return keys.count
    }
    
    public var isEmpty: Bool {
        return count == 0
    }
    
    public init() { }
    
    public subscript(index: Int) -> V? {
        get { get(at: index) }
        set { set(value: newValue, at: index) }
    }
    
    public subscript(key: K) -> V? {
        get { get(for: key) }
        set { set(value: newValue, for: key) }
    }
    
    public func get(at index: Int) -> V? {
        key2value[keys[index]]
    }
    
    public func set(value: V?, at index: Int) {
        let key = keys[index]
        if value != nil {
            key2value[key] = value
        } else {
            key2value.removeValue(forKey: key)
            keys.remove(at: index)
        }
    }
    
    public func get(for key: K) -> V? {
        key2value[key]
    }
    
    public func set(value: V?, for key: K) {
        if let value = value {
            let oldValue = key2value.updateValue(value, forKey: key)
            if oldValue == nil {
                keys.append(key)
            }
        } else {
            key2value.removeValue(forKey: key)
            if let index = keys.firstIndex(of: key) {
                keys.remove(at: index)
            }
        }
    }
    
    public func insert(_ key: K, andValue value: V, atIndex index: Int) {
        if keys.contains(key) {
            self[key] = nil
        }
        keys.insert(key, at: index <= keys.count ? index : keys.count)
        key2value[key] = value
    }
    
    public func indexOf(_ key: K) -> Int? {
        if let _  = key2value[key] {
            return keys.firstIndex(of: key)
        } else {
            return nil
        }
    }
        
    public func clear() {
        keys.removeAll(keepingCapacity: false)
        key2value.removeAll(keepingCapacity: false)
    }
    
    public func replace(with pairs: [(key: K, value: V)]) {
        clear()
        pairs.forEach {
            set(value: $0.value, for: $0.key)
        }
    }
}

extension OrderedDictionary: CustomStringConvertible {
    public var description: String {
        var result = "{\n"
        for i in 0...count {
            result += "[\(i)]: \(keys[i]) => \(String(describing: self[i]))\n"
        }
        result += "}"
        return result
    }
}
