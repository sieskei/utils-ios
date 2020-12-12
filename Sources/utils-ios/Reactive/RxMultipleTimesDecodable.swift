//
//  RxMultipleTimesDecodable.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation
import RxSwift

public protocol RxMultipleTimesDecodable: MultipleTimesDecodable, AssociatedObjectCompatible, ReactiveCompatible { }

internal extension RxMultipleTimesDecodable {
    var decodeNotifier: Notifier<Self> {
        return get(for: "decodeNotifier") { .init() }
    }
}

// MARK: Only for testing.
internal extension RxMultipleTimesDecodable {
    func simulateDecode() {
        decodeNotifier.notify(self)
    }
}

extension RxMultipleTimesDecodable {
    public func runDecode(from decoder: Decoder) throws {
        defer {
            decodeNotifier.notify(self)
        }
        
        try synchronized {
            try decode(from: decoder)
        }
    }
}

public extension Reactive where Base: RxMultipleTimesDecodable {
    var decode: Observable<Base> {
        return base.decodeNotifier.asObservable()
    }
}
