//
//  Utils+Task.swift
//  
//
//  Created by Miroslav Yozov on 1.11.19.
//

import Foundation
import RxSwift

public extension NSLock {
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

public extension NSLocking {
    @discardableResult
    func `guard`<T>(_ block: () throws -> T) rethrows -> T {
        self.lock(); defer { self.unlock() }
        return try block()
    }
    
    @discardableResult
    func unguard<T>(_ block: () throws -> T) rethrows -> T {
        unlock(); defer { lock() }
        return try block()
    }
}

public extension DispatchQueue {
    func async(guard: NSLocking, block: @escaping () -> Void) {
        async {
            `guard`.guard(block)
        }
    }
}

public extension Utils {
    struct Task {
        public typealias Lock = NSLocking
        
        public static var concurrentUtilityQueue: DispatchQueue = {
            return DispatchQueue(label: "bg.netinfo.Task.dispatchQueue.stuff", qos: .utility, attributes: .concurrent)
        }()
        
        private static var operationQueue: OperationQueue = {
            let queue = OperationQueue()
            queue.name = "bg.netinfo.Task.operationQueue.stuff"
            queue.underlyingQueue = concurrentUtilityQueue
            return queue
        }()
        
        public static func async(guard: Synchronized, block: @escaping () -> Void) {
            operationQueue.addOperation {
                `guard`.synchronized(block)
            }
        }
        
        public static func async(guard: Lock, block: @escaping () -> Void) {
            operationQueue.addOperation {
                `guard`.guard(block)
            }
        }
        
        public static func async(block: @escaping () -> Void) {
            operationQueue.addOperation(block)
        }
        
        public static func async(operation: Operation) {
            operationQueue.addOperation(operation)
        }
        
        public static func batchSync(operations: () -> Void ...) {
            operationQueue.addOperations(operations.map {
                return BlockOperation(block: $0)
            }, waitUntilFinished: true)
        }
    }
}

extension Utils.Task: ReactiveCompatible { }

public extension Reactive where Base == Utils.Task {
    static let scheduler: ConcurrentDispatchQueueScheduler = {
        return  .init(queue: Base.concurrentUtilityQueue)
    }()
}
