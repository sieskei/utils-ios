//
//  RxCoordinator.swift
//  
//
//  Created by Miroslav Yozov on 7.04.21.
//

import UIKit
import RxSwift
import RxSwiftExt

/// Base abstract coordinator generic over the return type of the `start` method.
open class RxCoordinator<OutputType> {
    /// Typealias which will allows to access a OutputType of the Coordainator by `CoordinatorName.CoordinationOutput`.
    public typealias CoordinationOutput = OutputType
    
    /// Coordinator's dismiss trigger.
    public enum DismissTrigger {
        case output
        case disappear
        case error(Error)
    }
    
    /// Coordinator's life cycle.
    public enum LifeCycle {
        case present(UIViewController)
        case event(OutputType)
        case dismiss(UIViewController, trigger: DismissTrigger = .output)
    }
    
    /// Coordinator's job events.
    
    fileprivate enum Event {
        case event(OutputType)
        case dismiss
    }
    
    /// Utility `DisposeBag` used by the subclasses.
    public let disposeBag = DisposeBag()

    /// Unique identifier.
    private let identifier = UUID()

    /// Dictionary of the child coordinators. Every child coordinator should be added
    /// to that dictionary in order to keep it in memory.
    /// Key is an `identifier` of the child coordinator and value is the coordinator itself.
    /// Value type is `Any` because Swift doesn't allow to store generic types in the array.
    private var childCoordinators = [UUID: Any]()
    
    public init() { }

    /// Stores coordinator to the `childCoordinators` dictionary.
    ///
    /// - Parameter coordinator: Child coordinator to store.
    private func store<T>(coordinator: RxCoordinator<T>) {
        childCoordinators[coordinator.identifier] = coordinator
    }

    /// Release coordinator from the `childCoordinators` dictionary.
    ///
    /// - Parameter coordinator: Coordinator to release.
    private func free<T>(coordinator: RxCoordinator<T>) {
        childCoordinators[coordinator.identifier] = nil
    }
    
    /// Calls method `start()` on that coordinator.
    ///
    /// - Parameter coordinator: Coordinator to start.
    /// - Returns: Result of `start()` method.
    public func move<T>(to coordinator: RxCoordinator<T>, untilDismiss: Bool = true) -> Observable<RxCoordinator<T>.LifeCycle> {
        let queue: RxCoordinator<T>.Queue = .init()
        let controller = coordinator.start(output: queue.input)
        
        return queue.output
            .withUnretained(controller)
            .map {
                switch $0.1 {
                case .event(let r):
                    return .event(r)
                case .dismiss:
                    return .dismiss($0.0, trigger: .output)
                }
            }
            .merge(with: { // convert disappear in dismiss
                controller.rx.viewDidDisappear
                    .withUnretained(controller)
                    .filter { ($0.0.isMovingFromParent || $0.0.isBeingDismissed) && untilDismiss }
                    .map { .dismiss($0.0, trigger: .disappear) }
            }())
            .catch { // convert error in dismiss
                .just(.dismiss(controller, trigger: .error($0)))
            }
            .take(until: { $0.isDismiss }, behavior: .inclusive)
            .startWith(.present(controller))
            .do(weak: self, onCompleted: { this in
                this.free(coordinator: coordinator)
            }, onSubscribe: { this in
                this.store(coordinator: coordinator)
            })
    }
    
    /// Starts job of the coordinator.
    ///
    /// - Parameter output: Output events of coordinator job.
    /// - Returns: Controller of coordinator.
    open func start(output: AnyObserver<OutputType>) -> UIViewController {
        fatalError("Start method should be implemented.")
    }
}

fileprivate extension RxCoordinator {
    /// IO events queue.
    /// Used for internal purposes.
    class Queue {
        private class Observer: ObserverType {
            typealias Element = OutputType
            
            fileprivate let subject: PublishSubject<Event> = .init()
            
            func on(_ event: RxSwift.Event<Element>) {
                switch event {
                case .next(let e):
                    subject.on(.next(.event(e)))
                case .error(let error):
                    subject.on(.error(error))
                case .completed: // convert completed to dismiss
                    subject.on(.next(.dismiss))
                }
            }
        }
        
        private let observer: Observer = .init()
        
        var input: AnyObserver<OutputType> {
            observer.asObserver()
        }
        
        var output: Observable<Event> {
            observer.subject.asObservable()
        }
    }
}

/// Coordinator dismiss trigger utilities.
public extension RxCoordinator.DismissTrigger {
    var isDisappear: Bool {
        switch self {
        case .disappear:
            return true
        default:
            return false
        }
    }
}

/// Coordinator life cycle utilities.
public extension RxCoordinator.LifeCycle {
    var isPresent: Bool {
        switch self {
        case .present:
            return true
        default:
            return false
        }
    }
    
    var isDismiss: Bool {
        switch self {
        case .dismiss:
            return true
        default:
            return false
        }
    }
}
