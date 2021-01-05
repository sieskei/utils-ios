//
//  OrderedDictionary.swift
//  
//
//  Created by Miroslav Yozov on 21.12.20.
//

import Foundation

public protocol OrderedDictionaryDelegate: class {
    associatedtype K: Hashable
    associatedtype V
    
    func orderedDictionary(didChanged dictionary: OrderedDictionary<K, V>)
}

fileprivate class AnyOrderedDictionaryDelegate<K: Hashable, V>: OrderedDictionaryDelegate {
    private var didChanged: (OrderedDictionary<K, V>) -> Void

    init<D: OrderedDictionaryDelegate>(_ delegate: D) where D.K == K, D.V == V {
        didChanged = { [weak delegate] in
            delegate?.orderedDictionary(didChanged: $0)
        }
    }
    
    func orderedDictionary(didChanged dictionary: OrderedDictionary<K, V>) {
        didChanged(dictionary)
    }
}

public class OrderedDictionary<K: Hashable, V> {
    fileprivate typealias D = AnyOrderedDictionaryDelegate<K, V>
    private var delegates: MulticastDelegate<D, StrongReference<D>>?
    
    private var key2value: [K: V] = [:]
    public private (set) var keys: [K] = []
    
    public var values: [V] {
        keys.map { key2value[$0]! }
    }
    
    public var count: Int {
        assert(keys.count == key2value.count, "Keys and values array out of sync.")
        return keys.count
    }
    
    public var isEmpty: Bool {
        count == 0
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
    
    public func indexOf(_ key: K) -> Int? {
        key2value[key] != nil ? keys.firstIndex(of: key) : nil
    }
    
    public func get(at index: Int) -> V? {
        key2value[keys[index]]
    }
    
    public func get(for key: K) -> V? {
        key2value[key]
    }
    
    public func set(value: V?, at index: Int) {
        defer {
            delegates => { $0.orderedDictionary(didChanged: self) }
        }
        
        let key = keys[index]
        if value != nil {
            key2value[key] = value
        } else {
            keys.remove(at: index)
            key2value.removeValue(forKey: key)
        }
    }
    
    public func set(value: V?, for key: K) {
        defer {
            delegates => { $0.orderedDictionary(didChanged: self) }
        }
        
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
    
    public func insert(_ key: K, _ value: V, at index: Int) {
        defer {
            delegates => { $0.orderedDictionary(didChanged: self) }
        }
        
        if let i = keys.firstIndex(of: key), i != index {
            keys.remove(at: i)
            keys.insert(key, at: index)
        }
        
        key2value[key] = value
    }
    
    public func clear() {
        defer {
            delegates => { $0.orderedDictionary(didChanged: self) }
        }
        
        keys.removeAll(keepingCapacity: false)
        key2value.removeAll(keepingCapacity: false)
    }
    
    public func replace(with pairs: [(key: K, value: V)]) {
        defer {
            delegates => {
                $0.orderedDictionary(didChanged: self)
            }
        }
        
        keys.removeAll(keepingCapacity: false)
        key2value.removeAll(keepingCapacity: false)
        
        pairs.forEach {
            keys.append($0.key)
            key2value[$0.key] = $0.value
        }
    }
    
    public func set<D: OrderedDictionaryDelegate>(delegate: D) where D.K == K, D.V == V {
        delegates += .init(delegate)
    }
    
    public func remove<D: OrderedDictionaryDelegate>(delegate: D) where D.K == K, D.V == V {
        // delegates -= delegate
    }
}

extension OrderedDictionary: CustomStringConvertible {
    public var description: String {
        var result = "{\n"
        for i in 0 ..< count {
            let key = keys[i]
            result += "[\(i)]: \(key) => \(String(describing: key2value[key]))\n"
        }
        result += "}"
        return result
    }
}
