//
//  CommandScheduler.swift
//  
//
//  Created by Miroslav Yozov on 30.11.21.
//

import Foundation
import RxSwift

public indirect enum Command<ActionType>: ObservableType {
    case action(ActionType, observer: PublishSubject<Element> = .init(), next: Command<ActionType> = .none)
    case none

    public var isNone: Bool {
        switch self {
        case .none:
            return true
        case .action:
            return false
        }
    }

    fileprivate mutating func push(action a: ActionType) -> Command {
        switch self {
        case .none:
            self = .action(a, next: .none)
            return self
        case .action(let action, let observer, var next):
            defer {
                self = .action(action, observer: observer, next: next)
            }
            return next.push(action: a)
        }
    }

    fileprivate mutating func pop() {
        switch self {
        case .action(_, _, let next):
            self = next
        case .none:
            break
        }
    }

    fileprivate func run() {
        switch self {
        case .action(let action, let observer, _):
            observer.on(.next(action))
        case .none:
            break
        }
    }


    // MARK: ObservableType
    public typealias Element = ActionType

    public func subscribe<Observer>(_ observer: Observer) -> Disposable where Observer : ObserverType, Element == Observer.Element {
        switch self {
        case .none:
            return Disposables.create()
        case .action(_, let current, _):
            return current.subscribe(observer)
        }
    }
}

public class CommandScheduler<ActionType> {
    public typealias DoType = (ActionType, @escaping Completable.CompletableObserver) -> Disposable
    
    private let lock: NSLock = .init()
    fileprivate var command: Command<ActionType> = .none
    
    public init() { }
    
    public func schedule(action: ActionType, `do`: @escaping DoType) -> Disposable {
        lock.guard {
            let runCommandImmediately = command.isNone
            let command = command.push(action: action)

            return command
                .take(1)
                .concatMap { action -> Completable in
                    Completable.create {
                        `do`(action, $0)
                    }
                }
                .do(with: self, onSubscribed: { this in
                    if runCommandImmediately {
                        this.command.run()
                    }
                }, onDispose: { this in
                    this.command.pop()
                    this.command.run()
                })
                .subscribe()

        }
    }
}

public extension Command where ActionType: Interruptible {
    mutating func interrupt() {
        switch self {
        case .none:
            break
        case .action(let action, _, let next):
            action.interrupt()
            self = next
        }
    }
}

public extension CommandScheduler where ActionType: Interruptible {
    func interrupt() {
        while !command.isNone {
            command.interrupt()
        }
    }
}
