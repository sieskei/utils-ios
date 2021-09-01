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
    /// Typealias which will allows to access a OutputType of the Coordainator by `CoordinatorName.CoordinationResult`.
    public typealias CoordinationOutput = OutputType
    
    /// Typealias for controller and job events.
    public typealias CoordinationStart = (controller: UIViewController, events: Observable<Event>)
    
    /// Coordinator's life cycle.
    public enum LifeCycle {
        case present(UIViewController)
        case event(OutputType)
        case dismiss(UIViewController, isEvent: Bool = true)
    }
    
    /// Coordinator's job events.
    public enum Event {
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
    public func move<T>(to coordinator: RxCoordinator<T>) -> Observable<RxCoordinator<T>.LifeCycle> {
        let start: RxCoordinator<T>.CoordinationStart = coordinator.start()
        let controller = start.controller
        
        return start.events
            .withUnretained(controller)
            .map {
                switch $0.1 {
                case .event(let r):
                    return .event(r)
                case .dismiss:
                    return .dismiss($0.0, isEvent: true)
                }
            }
            .merge(with: {
                controller.rx.viewDidDisappear
                    .withUnretained(controller)
                    .filter { $0.0.isMovingFromParent || $0.0.isBeingDismissed }
                    .map { .dismiss($0.0, isEvent: false) }
            }())
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
    /// - Returns: Controller and events of coordinator job.
    open func start() -> CoordinationStart {
        fatalError("Start method should be implemented.")
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
    
    func on(present call: (UIViewController) -> Void) {
        if case .present(let vc) = self {
            call(vc)
        }
    }
    
    func on(event call: (OutputType) -> Void) {
        if case .event(let r) = self {
            call(r)
        }
    }
    
    func on(dismiss call: (UIViewController, Bool) -> Void) {
        if case .dismiss(let vc, let flag) = self {
            call(vc, flag)
        }
    }
}

/// Coordinator job event utilities.
public extension RxCoordinator.Event {
    var isDismiss: Bool {
        switch self {
        case .dismiss:
            return true
        default:
            return false
        }
    }
    
    func on(event call: (OutputType ) -> Void) {
        if case .event(let r) = self {
            call(r)
        }
    }
    
    func on(dismiss call: () -> Void) {
        if case .dismiss = self {
            call()
        }
    }
}
