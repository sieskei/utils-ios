//
//  RxCoordinator.swift
//  
//
//  Created by Miroslav Yozov on 7.04.21.
//

import UIKit
import RxSwift
import RxSwiftExt

extension RxCoordinator {
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
            
            /// Method suspend is called.
            case suspended
            
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
}

/// Base abstract coordinator generic over the return type of the `start` method.
open class RxCoordinator<OutputType>: UtilsUICoordinatorsConnectable, Interruptible, ReactiveCompatible {
    /// Utility `DisposeBag` used by the subclasses.
    public let disposeBag = DisposeBag()

    /// Unique identifier.
    private let identifier = UUID()
    
    /// Dictionary of the child coordinators. Every child coordinator should be added
    /// to that dictionary in order to keep it in memory.
    /// Key is an `identifier` of the child coordinator and value is the coordinator itself.
    private var childCoordinators = [UUID: UtilsUICoordinatorsConnectable]()
    
    
    // MARK: - UtilsUICoordinatorsConnectable
    
    /// Connection to parent.
    @RxProperty
    internal var connection: Utils.UI.Coordinators.Connection? = nil
    
    internal var connectionsToBeResume: [Utils.UI.Coordinators.Connection] {
        var all: [Utils.UI.Coordinators.Connection?] = []
        all.append(connection)
        childCoordinators.values.forEach {
            if let c = $0.connection, case .suspended(.parent) = c.state.value {
                all.append(contentsOf: $0.connectionsToSuspend)
            }
        }
        return all.compactMap { $0 }
    }
    
    internal var connectionsToSuspend: [Utils.UI.Coordinators.Connection] {
        var all: [Utils.UI.Coordinators.Connection?] = []
        all.append(connection)
        childCoordinators.values.forEach {
            if let c = $0.connection, case .established = c.state.value {
                all.append(contentsOf: $0.connectionsToSuspend)
            }

        }
        return all.compactMap { $0 }
    }
    
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
    public final func connect<T>(to coordinator: RxCoordinator<T>, untilDismiss: Bool = true, startImmediately: Bool = true) -> Observable<RxCoordinator<T>.LifeCycle> {
        coordinator.connect(untilDismiss: untilDismiss, startImmediately: startImmediately)
            .do(with: self, onSubscribe: { this in
                this.store(coordinator: coordinator)
            }, onDispose: { this in
                this.free(coordinator: coordinator)
            })
    }
    
    public final func connect(untilDismiss: Bool = true, startImmediately: Bool = true) -> Observable<LifeCycle> {
        let c: Utils.UI.Coordinators.Connection = .init(startImmediately: startImmediately, untilDismiss: untilDismiss)
        connection = c
        
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
                controller.rx.dismissed // skip if previously was suspended
                    .filterMap {
                        switch c.state.value {
                        case .established:
                            return .map(.dismiss($0, trigger: .disappear))
                        case .suspended: // ignore, already produced dismiss by link state, see bellow
                            return .ignore
                        }
                    }
            }())
            .merge(with: { // convert disconnect method to dismiss
                $connection.value
                    .filter { $0 == nil }
                    .withUnretained(controller)
                    .map { .dismiss($0.0, trigger: .disconnect) }
            }())
            .merge(with: { // convert connection state to present or dismiss
                c.state.asObservable()
                    .scan((c.state.value, c.state.value), accumulator: { ($0.1, $1) })
                    .skip(1) // skip initial velue
                    .filterMap { pair in
                        switch pair.1 {
                        // produce present only when previously was own suspend
                        case .established where pair.0 == .suspended(trigger: .`self`):
                            return .map(.present(controller))
                        // produce dismiss only when own suspend
                        case .suspended(.`self`):
                            return .map(.dismiss(controller, trigger: .suspended))
                        default:
                            return .ignore
                        }
                    }
            }())
            .catch { // convert error to dismiss
                .just(.dismiss(controller, trigger: .error($0)))
            }
            .`if`(startImmediately) {
                $0.startWith(.present(controller))
            }
            .distinctUntilChanged { lhs, rhs in
                // protection from repeated present/dismiss
                if rhs.isPresent {
                    return lhs.isPresent
                } else if rhs.isDismiss {
                    return lhs.isDismiss
                } else {
                    return false
                }
            }
            .take(until: {
                $0.isDismiss && c.untilDismiss
            }, behavior: .inclusive)
    }
    
    public final func suspend() {
        guard let connection, connection.isEstablished else {
            return
        }
        
        let all: [Utils.UI.Coordinators.Connection] = .init(connectionsToSuspend.reversed())
        switch all.count {
        case 0:
            return
        case 1:
            all[0].suspend()
        default:
            all[0...all.count - 2].forEach { $0.suspend(by: .parent) }
            all[all.count - 1].suspend()
        }
    }
    
    public final func resume() {
        guard let connection, connection.isSuspended else {
            return
        }
        
        connectionsToBeResume.forEach { $0.resume() }
    }
    
    public final func disconnect() {
        connection = nil
    }
    
    // MARK: - Interruptible
    
    public final func interrupt() {
        disconnect()
    }
}

fileprivate extension RxCoordinator {
    /// IO events queue.
    /// Used for internal purposes.
    class IO {
        private let io: PublishSubject<Event> = .init()
        
        var i: AnyObserver<OutputType> {
            .init { [weak io = io] in
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
    
    func onPresent(_ `do`: (UIViewController) -> Void) {
        switch self {
        case .present(let vc):
            `do`(vc)
        default:
            break
        }
    }
}


