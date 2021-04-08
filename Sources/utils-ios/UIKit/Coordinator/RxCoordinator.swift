//
//  RxCoordinator.swift
//  
//
//  Created by Miroslav Yozov on 7.04.21.
//

import Foundation
import RxSwift

open class RxCoordinator<ResultType> {
    public typealias CoordinationResult = ResultType

    public let disposeBag = DisposeBag()
    
    private let identifier = UUID()
    private var childCoordinators = [UUID: Any]()

    private func store<T>(coordinator: RxCoordinator<T>) {
        childCoordinators[coordinator.identifier] = coordinator
    }

    private func release<T>(coordinator: RxCoordinator<T>) {
        childCoordinators[coordinator.identifier] = nil
    }

    @discardableResult
    open func coordinate<T>(to coordinator: RxCoordinator<T>) -> Observable<T> {
        store(coordinator: coordinator)
        
        return coordinator.start()
            .do(weak: self, onNext: { this, _ in
                this.release(coordinator: coordinator)
            })
    }

    open func start() -> Observable<ResultType> {
        fatalError("start() method must be implemented")
    }
}
