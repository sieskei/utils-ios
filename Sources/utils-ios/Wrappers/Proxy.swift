//
//  Proxy.swift
//  
//
//  Created by Miroslav Yozov on 31.03.21.
//

import Foundation

@propertyWrapper
public struct Proxy<EnclosingType, Value> {
    public typealias ValueKeyPath = ReferenceWritableKeyPath<EnclosingType, Value>
    public typealias SelfKeyPath = ReferenceWritableKeyPath<EnclosingType, Self>

    public static subscript(_enclosingInstance instance: EnclosingType, wrapped wrappedKeyPath: ValueKeyPath, storage storageKeyPath: SelfKeyPath) -> Value {
        get { instance[keyPath: instance[keyPath: storageKeyPath].keyPath] }
        set { instance[keyPath: instance[keyPath: storageKeyPath].keyPath] = newValue }
    }

    @available(*, unavailable, message: "@Proxy can only be applied to classes")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }

    private let keyPath: ValueKeyPath

    public init(_ path: ValueKeyPath) {
        keyPath = path
    }
}
