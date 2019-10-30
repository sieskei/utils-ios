//
//  Utils.swift
//  
//
//  Created by Miroslav Yozov on 29.10.19.
//

import Foundation
import RxSwift
import RxCocoa

public struct Utils {
    private init() { }
    
    static func unwrapOrFatalError<T>(_ value: T?) -> T {
        guard let result = value else {
            fatalError("Failure unwrap to \(T.self)")
        }
        return result
    }
    
    static func castOrFatalError<T>(_ value: Any) -> T {
        let maybeResult: T? = value as? T
        guard let result = maybeResult else {
            fatalError("Failure converting from \(String(describing: value)) to \(T.self)")
        }
        
        return result
    }
}
