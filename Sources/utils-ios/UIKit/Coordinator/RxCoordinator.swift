//
//  RxCoordinator.swift
//  
//
//  Created by Miroslav Yozov on 7.04.21.
//

import UIKit
import RxSwift

/// Base abstract coordinator generic over the return type of the `start` method.
open class RxCoordinator<ResultType> {
    /// Typealias which will allows to access a ResultType of the Coordainator by `CoordinatorName.CoordinationResult`.
    public typealias CoordinationResult = ResultType
    
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

    /// 1. Calls method `start()` on that coordinator.
    /// 2. On the `onSubscribe:` of returning observable of method `start()` stores coordinator in a dictionary of child coordinators.
    /// 3. On the `afterCompleted:` of returning observable of method `start()` removes coordinator from the dictionary.
    ///
    /// - Parameter coordinator: Coordinator to start.
    /// - Returns: Result of `start()` method.
    public func coordinate<T>(to coordinator: RxCoordinator<T>) -> Observable<T> {
        coordinator
            .start()
            .do(weak: self, afterCompleted: {
                $0.free(coordinator: coordinator)
            }, onSubscribe: {
                $0.store(coordinator: coordinator)
            })
    }
    
    /// Starts job of the coordinator.
    ///
    /// - Returns: Result of coordinator job.
    open func start() -> Observable<ResultType> {
        fatalError("Start method should be implemented.")
    }
}
