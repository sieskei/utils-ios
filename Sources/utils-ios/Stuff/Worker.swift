//
//  Worker.swift
//  
//
//  Created by Miroslav Yozov on 15.05.20.
//

import Foundation

public class Worker {
    private static let queueKey = DispatchSpecificKey<Int>()
    private lazy var queueContext = unsafeBitCast(self, to: Int.self)
    private lazy var queue: DispatchQueue = {
        let value = DispatchQueue(label: "ios.utils.App.Worker")
        value.setSpecific(key: Worker.queueKey, value: queueContext)
        return value
    }()
    
    public init() { }

    private func dispatchSync<T>(_ block: () throws -> T) rethrows -> T {
        if DispatchQueue.getSpecific(key: Worker.queueKey) != queueContext {
            print("not in queue")
            return try queue.sync(execute: block)
        }
        
        print("in queue")
        return try block()
    }
    
    public func test(x: Int) -> Int {
        return dispatchSync {
            return x > 2 ? test(x: x - 1) * x : x
        }
    }
}
