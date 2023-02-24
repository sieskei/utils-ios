//
//  RxCoordinator+IO.swift
//  
//
//  Created by Miroslav Yozov on 1.07.21.
//

import UIKit
import RxSwift

open class RxIOCoordinator<InputType, OutputType>: RxCoordinator<OutputType> {
    /// Typealias which will allows to access a InputType of the Coordainator by `CoordinatorName.CoordinationInput`.
    public typealias CoordinationInput = InputType
    
    private let notifier: BufferedNotifier<InputType> = .init()
    
    public final var input: Binder<InputType> {
        input()
    }
    
    public final func input(scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance) -> Binder<InputType> {
        .init(self, scheduler: scheduler) {
            $0.notifier.onNext($1)
        }
    }
    
    public final override func start(output: AnyObserver<OutputType>) -> UIViewController {
        let controller = start(input: notifier.asObservable(), output: output)
        notifier.set(state: .passthrough)
        return controller
    }
    
    /// Starts job of the coordinator.
    ///
    /// - Parameter input: Input events from init method.
    /// - Parameter output: Output events of coordinator job.
    /// - Returns: Controller of coordinator.
    open func start(input: Observable<InputType>, output: AnyObserver<OutputType>) -> UIViewController {
        fatalError("Start(input:output:) method should be implemented.")
    }
}
