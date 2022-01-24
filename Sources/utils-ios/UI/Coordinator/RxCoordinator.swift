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
open class RxCoordinator<OutputType>: ReactiveCompatible, Interruptible {
    /// Typealias which will allows to access a OutputType of the Coordainator by `CoordinatorName.CoordinationOutput`.
    public typealias CoordinationOutput = OutputType
    
    /// Coordinator's life cycle.
    public enum LifeCycle {
        /// Coordinator's dismiss trigger.
        public enum DismissTrigger {
            /// Coordinator's view controller is still presented and want to be dismissed.
            case complete
            
            /// When coordinator's view controller is removed from the hierarchy without an outgoing event.
            case disappear
            
            /// When the parent-child reference is gone without an outgoing event.
            /// Method disconnect is called.
            case disconnect
            
            /// When an error occurs in the output.
            case error(Error)
        }
        
        case present(UIViewController)
        case event(OutputType)
        case dismiss(UIViewController, trigger: DismissTrigger = .complete)
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
    
    /// Connection to parent.
    private var connection: Connection? = nil

    /// Dictionary of the child coordinators. Every child coordinator should be added
    /// to that dictionary in order to keep it in memory.
    /// Key is an `identifier` of the child coordinator and value is the coordinator itself.
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
    
    /// Starts job of the coordinator.
    ///
    /// - Parameter output: Output events of coordinator job.
    /// - Returns: Controller of coordinator.
    open func start(output: AnyObserver<OutputType>) -> UIViewController {
        fatalError("Start method should be implemented.")
    }
    
    /// Calls method `start()` on that coordinator.
    ///
    /// - Parameter coordinator: Coordinator to start.
    /// - Returns: Result of `start()` method.
    public final func connect<T>(to coordinator: RxCoordinator<T>, untilDismiss flag: Bool = true) -> Observable<RxCoordinator<T>.LifeCycle> {
        coordinator.connect(untilDismiss: flag)
            .`do`(with: self, onCompleted: { this in
                this.free(coordinator: coordinator)
            }, onSubscribe: { this in
                this.store(coordinator: coordinator)
            })
    }
    
    public final func connect(untilDismiss: Bool = true) -> Observable<LifeCycle> {
        let conn: Connection = .init()
        connection = conn
        
        let queue: IO = .init()
        let controller = start(output: queue.i)
        
        return queue.o
            .withUnretained(controller)
            .map {
                switch $0.1 {
                case .event(let r):
                    return .event(r)
                case .dismiss:
                    return .dismiss($0.0, trigger: .complete)
                }
            }
            .merge(with: { // convert disappear to dismiss
                controller.rx.dismissed
                    .map { .dismiss($0, trigger: .disappear) }
            }())
            .merge(with: { // convert connection deallocation to dismiss
                conn.rx.deallocated
                    .withUnretained(controller)
                    .map { .dismiss($0.0, trigger: .disconnect) }
            }())
            .catch { // convert error to dismiss
                .just(.dismiss(controller, trigger: .error($0)))
            }
            .take(until: { $0.isDismiss && untilDismiss }, behavior: .inclusive)
            .startWith(.present(controller))
    }
    
    public final func disconnect() {
        connection = nil
    }
    
    public final func interrupt() {
        disconnect()
    }
}

fileprivate extension RxCoordinator {
    /// Object represent connection between parent-child.
    /// Used for internal purposes.
    class Connection: ReactiveCompatible { }
}

fileprivate extension RxCoordinator {
    /// IO events queue.
    /// Used for internal purposes.
    class IO {
        private let io: PublishSubject<Event> = .init()
        
        var i: AnyObserver<OutputType> {
            .init { [weak io] in
                guard let io = io else {
                    return
                }
                
                switch $0 {
                case .next(let e):
                    io.on(.next(.event(e)))
                case .error(let error):
                    io.on(.error(error))
                case .completed: // convert completed to dismiss
                    io.on(.next(.dismiss))
                }
            }
        }
        
        var o: Observable<Event> {
            io.asObservable()
        }
    }
}

/// Coordinator dismiss trigger utilities.
public extension RxCoordinator.LifeCycle.DismissTrigger {
    var isDisappear: Bool {
        switch self {
        case .disappear:
            return true
        default:
            return false
        }
    }
    
    var isDisconnect: Bool {
        switch self {
        case .disconnect:
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

public extension Reactive where Base: UIViewController {
    var presented: Observable<UIViewController> {
        base.rx
            .methodInvoked(#selector(Base.viewDidAppear(_:)))
            .withUnretained(base)
            .map { $0.0 }
            .filter { $0.isMovingToParent || $0.isBeingPresented }
    }
    
    var dismissed: Observable<UIViewController> {
        base.rx
            .methodInvoked(#selector(Base.viewDidDisappear(_:)))
            .withUnretained(base)
            .map { $0.0 }
            .filter { $0.isMovingFromParent || $0.isBeingDismissed }
    }
}
