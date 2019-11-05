//
//  RxMultipleTimesDecodable.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation
import RxSwift

// MARK: Small `Value` helper methods.
fileprivate extension Value where Element == Void {
    static var instance: Value<Element> { return .init(()) }
    
    func next() { value = () }
}

public protocol RxMultipleTimesDecodable:
    MultipleTimesDecodable,
    Synchronized,
    AssociatedObjectCompatible,
    ReactiveCompatible { }

internal extension RxMultipleTimesDecodable {
    var valueDecode: Value<Void> {
        return get(for: "valueDecode") { .instance }
    }
}

public extension RxMultipleTimesDecodable {
    func runDecode(from decoder: Decoder) throws {
        defer {
            valueDecode.next()
        }
        
        try synchronized {
            try decode(from: decoder)
        }
    }
}


// MARK: Only for testing.
internal extension RxMultipleTimesDecodable {
    func simulateDecode() {
        valueDecode.next()
    }
}

public extension Reactive where Base: RxMultipleTimesDecodable {
    var decode: Observable<Base> {
        return base.valueDecode.skip(1).map { [unowned base] _ in
            return base
        }
    }
}
