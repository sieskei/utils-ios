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
    
    func orderedDictionary(changed dictionary: OrderedDictionary<K, V>)
}

fileprivate class AnyOrderedDictionaryDelegate<K: Hashable, V>: OrderedDictionaryDelegate {
    private let change: (OrderedDictionary<K, V>) -> Void
    
    private let identifier: () -> Int
    private let аlive: () -> Bool
    
    var isAlive: Bool {
        аlive()
    }

    init<D: OrderedDictionaryDelegate>(_ delegate: D) where D.K == K, D.V == V {
        identifier = { [weak delegate] in
            delegate != nil ? ObjectIdentifier(delegate!).hashValue : -1
        }
        
        change = { [weak delegate] in
            delegate?.orderedDictionary(changed: $0)
        }
        
        аlive = { [weak delegate] in
            delegate != nil
        }
    }
    
    func orderedDictionary(changed dictionary: OrderedDictionary<K, V>) {
        change(dictionary)
    }
    
    func `is`<D: OrderedDictionaryDelegate>(delegate: D) -> Bool {
        let hashValue = identifier()
        return hashValue != -1 && hashValue == ObjectIdentifier(delegate).hashValue
    }
}

public class OrderedDictionary<K: Hashable, V> {
    private typealias D = AnyOrderedDictionaryDelegate<K, V>
    
    private class DelegateReference: Reference {
        typealias T = D
        var delegate: T?
        
        var ref: T? {
            guard let ref = delegate, ref.isAlive else {
                delegate = nil
                return nil
            }
            return ref
        }
        
        required init(_ ref: T) {
            delegate = ref
        }
    }
    
    private var delegates: MulticastDelegate<D, DelegateReference>?
    
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
    
    fileprivate func doSet(value: V?, at index: Int) {
        let key = keys[index]
        if value != nil {
            key2value[key] = value
        } else {
            keys.remove(at: index)
            key2value.removeValue(forKey: key)
        }
    }
    
    fileprivate func doSet(value: V?, for key: K) {
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
}

// MARK: Getters
extension OrderedDictionary {
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
        guard !keys.isEmpty, index >= 0 && index < keys.count else {
            return nil
        }
        return key2value[keys[index]]
    }
    
    public func get(for key: K) -> V? {
        key2value[key]
    }
}

// MARK: Setters
extension OrderedDictionary {
    public func set(value: V?, at index: Int) {
        defer {
            delegates => { $0.orderedDictionary(changed: self) }
        }
        doSet(value: value, at: index)
    }
    
    public func set(value: V?, for key: K) {
        defer {
            delegates => { $0.orderedDictionary(changed: self) }
        }
        doSet(value: value, for: key)
    }
    
    public func insert(_ key: K, _ value: V, at index: Int) {
        defer {
            delegates => { $0.orderedDictionary(changed: self) }
        }
        
        if let i = keys.firstIndex(of: key), i != index {
            keys.remove(at: i)
            keys.insert(key, at: index)
        }
        
        key2value[key] = value
    }
    
    public func clear() {
        defer {
            delegates => { $0.orderedDictionary(changed: self) }
        }
        
        keys.removeAll(keepingCapacity: false)
        key2value.removeAll(keepingCapacity: false)
    }
    
    public func replace(with pairs: [(key: K, value: V)]) {
        defer {
            delegates => { $0.orderedDictionary(changed: self) }
        }
        
        keys.removeAll()
        key2value.removeAll()
        
        pairs.forEach {
            keys.append($0.key)
            key2value[$0.key] = $0.value
        }
    }
    
    public func append(all: [(key: K, value: V)]) {
        defer {
            delegates => { $0.orderedDictionary(changed: self) }
        }
        
        all.forEach {
            doSet(value: $0.value, for: $0.key)
        }
    }
}

// MARK: Delegates
extension OrderedDictionary {
    public func set<D: OrderedDictionaryDelegate>(delegate: D) where D.K == K, D.V == V {
        delegates += .init(delegate)
    }
    
    public func remove<D: OrderedDictionaryDelegate>(delegate: D) where D.K == K, D.V == V {
        guard let anyDelegate = delegates?.references.first(where: { $0.is(delegate: delegate) }) else {
            return
        }
        delegates -= anyDelegate
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
