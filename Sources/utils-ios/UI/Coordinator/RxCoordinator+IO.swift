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
    
    private enum Connection {
        case none(buffer: [InputType] = [])
        case established(PublishSubject<InputType>)
        
        mutating func transmit(_ input: InputType) {
            switch self {
            case .none(let buffer):
                self = .none(buffer: buffer + [input])
            case .established(let obsever):
                obsever.onNext(input)
            }
        }
        
        mutating func establish(to observer: PublishSubject<InputType>) {
            switch self {
            case .none(let buffer):
                buffer.forEach { observer.onNext($0) }
                fallthrough
            case .established:
                self = .established(observer)
            }
        }
    }
    
    private var connection: Connection = .none()
    
    public final var input: Binder<InputType> {
        input()
    }
    
    public final func input(scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance) -> Binder<InputType> {
        .init(self, scheduler: scheduler) {
            $0.connection.transmit($1)
        }
    }
    
    public final override func start(output: AnyObserver<OutputType>) -> UIViewController {
        let input: PublishSubject<InputType> = .init()
        let controller = start(input: input, output: output)
        connection.establish(to: input)
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
