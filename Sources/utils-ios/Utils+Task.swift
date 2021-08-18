//
//  Utils+Task.swift
//  
//
//  Created by Miroslav Yozov on 1.11.19.
//

import Foundation
import RxSwift

extension DispatchQueue {
    private struct QueueReference {
        weak var queue: DispatchQueue?
    }

    private static let key: DispatchSpecificKey<QueueReference> = {
        let key = DispatchSpecificKey<QueueReference>()
        setupSystemQueuesDetection(key: key)
        return key
    }()

    private static func registerDetection(of queues: [DispatchQueue], key: DispatchSpecificKey<QueueReference>) {
        queues.forEach { $0.setSpecific(key: key, value: QueueReference(queue: $0)) }
    }

    private static func setupSystemQueuesDetection(key: DispatchSpecificKey<QueueReference>) {
        let queues: [DispatchQueue] = [
                                        .main,
                                        .global(qos: .background),
                                        .global(qos: .default),
                                        .global(qos: .unspecified),
                                        .global(qos: .userInitiated),
                                        .global(qos: .userInteractive),
                                        .global(qos: .utility)
                                    ]
        registerDetection(of: queues, key: key)
    }
}

// MARK: public functionality

extension DispatchQueue {
    static func registerDetection(of queue: DispatchQueue) {
        registerDetection(of: [queue], key: key)
    }

    static var currentQueueLabel: String? { current?.label }
    static var current: DispatchQueue? { getSpecific(key: key)?.queue }
}

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

public extension DispatchTimeInterval {
    var isZero: Bool {
        switch self {
        case .seconds(let i):
            return i == 0
        case .milliseconds(let i):
            return i == 0
        case .microseconds(let i):
            return i == 0
        case .nanoseconds(let i):
            return i == 0
        case .never:
            return false
        @unknown default:
            return false
        }
    }
}

public extension Utils {
    struct Task {
        public typealias Lock = NSLocking
        
        public static var serialUtilityQueue: DispatchQueue = {
            let queue = DispatchQueue(label: "Utils.Task.Queue.utility.serial", qos: .utility)
            DispatchQueue.registerDetection(of: queue)
            return queue
        }()
        
        public static var concurrentUtilityQueue: DispatchQueue = {
            let queue = DispatchQueue(label: "Utils.Task.Queue.utility.concurrent", qos: .utility, attributes: .concurrent)
            DispatchQueue.registerDetection(of: queue)
            return queue
        }()
        
        private static var concurrentOperationQueue: OperationQueue = {
            let queue = OperationQueue()
            queue.name = "ios.utils.Task.operationQueue.stuff"
            queue.underlyingQueue = concurrentUtilityQueue
            return queue
        }()
        
        public static func async(guard: Synchronized, block: @escaping () -> Void) {
            concurrentOperationQueue.addOperation {
                `guard`.synchronized(block)
            }
        }
        
        public static func async(guard: Lock, block: @escaping () -> Void) {
            concurrentOperationQueue.addOperation {
                `guard`.guard(block)
            }
        }
        
        public static func async(block: @escaping () -> Void) {
            concurrentOperationQueue.addOperation(block)
        }
        
        public static func async(operation: Operation) {
            concurrentOperationQueue.addOperation(operation)
        }
        
        public static func batchSync(operations: () -> Void ...) {
            concurrentOperationQueue.addOperations(operations.map { BlockOperation(block: $0) }, waitUntilFinished: true)
        }
        
        public static func sync(_ operation: @escaping () -> Void) {
            batchSync(operations: operation)
        }
    }
}

extension Utils.Task: ReactiveCompatible { }

public extension Reactive where Base == Utils.Task {
    static let concurrentScheduler: SchedulerType = {
        return  ConcurrentDispatchQueueScheduler(queue: Base.concurrentUtilityQueue)
    }()
    
    static let serialScheduler: SchedulerType = {
        return ConcurrentDispatchQueueScheduler(queue: Base.serialUtilityQueue)
    }()
}
