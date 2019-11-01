//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

public protocol Synchronized { }
extension Synchronized {
    func synchronized<T>(_ action: () throws -> T) rethrows -> T {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        return try action()
    }
}
