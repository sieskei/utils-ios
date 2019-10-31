//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation
import RxSwift

fileprivate extension Value where Element == Void {
    func next() {
        value = ()
    }
}

public class RxMultipleTimesDecodable: MultipleTimesDecodable {
    fileprivate lazy var decode: Value<Void> = {
        return .init(())
    }()
    
    public func decode(from decoder: Decoder) throws {
        decode.next()
    }
}


// MARK: Reactive compatible.
extension RxMultipleTimesDecodable: ReactiveCompatible { }

public extension Reactive where Base: RxMultipleTimesDecodable {
    var decode: Observable<Base> {
        return base.decode.skip(1).map { [unowned base] _ in
            return base
        }
    }
}
