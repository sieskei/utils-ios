//
//  RxRedecodable.swift
//  
//
//  Created by Miroslav Yozov on 3.02.21.
//

import Foundation
import RxSwift

public protocol RxRedecodable: Redecodable, AssociatedObjectCompatible, ReactiveCompatible { }

internal extension RxRedecodable {
    var decodeNotifier: Notifier<Self> {
        return get(for: "decode.notifier") { .init() }
    }
}

// MARK: Only for testing.
internal extension RxRedecodable {
    func simulateDecode() {
        decodeNotifier.notify(self)
    }
}

extension RxRedecodable {
    public func runDecode(from decoder: Decoder) throws {
        defer {
            decodeNotifier.notify(self)
        }
        
        try synchronized {
            try decode(from: decoder)
        }
    }
}

public extension Reactive where Base: RxRedecodable {
    var decode: Observable<Base> {
        return base.decodeNotifier.asObservable()
    }
}
