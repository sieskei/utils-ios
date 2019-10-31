//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation
import RxSwift

fileprivate extension Value where Element == Void {
    static var instance: Value<Element> {
        return .init(())
    }
    
    func next() {
        value = ()
    }
}

public class RxMultipleTimesDecodable: MultipleTimesDecodable {
    fileprivate let decode: Value<Void>
    
    public init() {
        decode = .instance
    }
    
    public required init(from decoder: Decoder) throws {
        decode = .instance
    }
    
    public func decode(from decoder: Decoder) throws {
        decode.next()
    }
    
    public func testDecode() {
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
