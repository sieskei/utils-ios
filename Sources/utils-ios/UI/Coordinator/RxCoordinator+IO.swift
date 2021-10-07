//
//  RxCoordinator+IO.swift
//  
//
//  Created by Miroslav Yozov on 1.07.21.
//

import Foundation

import UIKit
import RxSwift
import RxSwiftExt

open class RxIOCoordinator<InputType, OutputType>: RxCoordinator<OutputType> {
    /// Typealias which will allows to access a InputType of the Coordainator by `CoordinatorName.CoordinationInput`.
    public typealias CoordinationInput = InputType
    
    private let input: PublishSubject<InputType> = .init()
    
    public final override func start(output: AnyObserver<OutputType>) -> UIViewController {
        start(input: input, output: output)
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

extension RxIOCoordinator: ObserverType {
    public typealias Element = InputType
    
    public func on(_ event: RxSwift.Event<Element>) {
        input.on(event)
    }
    
    public func on(_ event: InputType) {
        input.onNext(event)
    }
}
