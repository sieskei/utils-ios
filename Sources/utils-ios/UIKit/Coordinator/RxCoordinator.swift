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
open class RxCoordinator<ResultType> {
    /// Typealias which will allows to access a ResultType of the Coordainator by `CoordinatorName.CoordinationResult`.
    public typealias CoordinationResult = ResultType
    
    /// Typealias for controller and job events.
    public typealias CoordinationStart = (controller: UIViewController, events: Observable<Event>)
    
    /// Coordinator's life cycle.
    public enum LifeCycle {
        case present(UIViewController)
        case event(ResultType)
        case dismiss(UIViewController)
    }
    
    /// Coordinator's job events.
    public enum Event {
        case event(ResultType)
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
        return start.events
            .take(until: { $0.isDismiss }, behavior: .inclusive)
            .map {
                switch $0 {
                case .event(let r):
                    return .event(r)
                case .dismiss:
                    return .dismiss(start.controller)
                }
            }
            .startWith(.present(start.controller))
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
    
    var mapToEvent: FilterMap<RxCoordinator<ResultType>.Event> {
        switch self {
        case .event(let r):
            return .map(.event(r))
        case .dismiss:
            return .map(.dismiss)
        default:
            return .ignore
        }
    }
    
    func on(present call: (UIViewController) -> Void) {
        if case .present(let vc) = self {
            call(vc)
        }
    }
    
    func on(event call: (ResultType) -> Void) {
        if case .event(let r) = self {
            call(r)
        }
    }
    
    func on(dismiss call: (UIViewController) -> Void) {
        if case .dismiss(let vc) = self {
            call(vc)
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
    
    func on(event call: (ResultType) -> Void) {
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
