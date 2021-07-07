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

open class RxIOCoordinator<InputType, ResultType>: RxCoordinator<ResultType> {
    /// Typealias which will allows to access a ResultType of the Coordainator by `CoordinatorName.CoordinationInput`.
    public typealias CoordinationInput = InputType
    
    private let input: PublishSubject<InputType> = .init()
    
    public final override func start() -> CoordinationStart {
        start(input: input)
    }
    
    /// Starts job of the coordinator.
    ///
    /// - Parameter input: input events from init method.
    /// - Returns: Controller and events of coordinator job.
    open func start(input: Observable<InputType>) -> CoordinationStart {
        fatalError("Start(input:) method should be implemented.")
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
