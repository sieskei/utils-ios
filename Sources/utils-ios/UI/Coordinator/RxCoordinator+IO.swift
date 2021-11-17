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
    
    fileprivate let subject: PublishSubject<InputType> = .init()
    
    public final var input: Binder<InputType> {
        .init(self, scheduler: CurrentThreadScheduler.instance) { this, input in
            this.subject.onNext(input)
        }
    }
    
    public final override func start(output: AnyObserver<OutputType>) -> UIViewController {
        start(input: subject, output: output)
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
