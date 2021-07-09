//
//  SortedMap.swift
//  
//
//  Created by Miroslav Yozov on 9.07.21.
//

import Foundation

@propertyWrapper
public class SortedMap<K: Hashable, V> {
    public typealias MapType = [K: V]
    public typealias Comparator = (V, V) -> Bool
    
    public var wrappedValue: MapType {
        didSet {
            sortedValue = wrappedValue.values.sorted(by: cmp)
        }
    }
    
    public var projectedValue: Tools {
        .init(base: self)
    }
    
    fileprivate (set) var sortedValue: [V]
    private let cmp: Comparator
    
    public init(wrappedValue: MapType, by cmp: @escaping Comparator) {
        self.cmp = cmp
        self.wrappedValue = wrappedValue
        self.sortedValue = wrappedValue.values.sorted(by: cmp)
    }
}

public extension SortedMap {
    class Tools {
        public private (set) var base: SortedMap<K, V>
        
        public var sorted: [V] {
            base.sortedValue
        }

        init(base: SortedMap<K, V>) {
            self.base = base
        }
    }
}
