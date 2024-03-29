//
//  Fault+Throw.swift
//  
//
//  Created by Miroslav Yozov on 27.10.21.
//

import UIKit
import RxSwift

extension Fault {
    fileprivate static let thrower: BufferedNotifier<Fault.Throw> = .init(state: .passthrough)
    
    public static func wait() { thrower.set(state: .buffer) }
    public static func signal() { thrower.set(state: .passthrough) }
}

extension Fault {
    public struct Throw {
        fileprivate let subject: PublishSubject<Action> = .init()
        
        public let fault: Fault
        public let actions: [Action]
        
        public let animated: Bool
        public let autodismiss: Bool
        
        public func `catch`(with action: Action) {
            guard !subject.isDisposed else {
                utils_ios.Utils.Log.warning("Already catched!", self)
                return
            }
            
            subject.on(.next(action))
            subject.on(.completed)
        }
    }
}

extension Fault.Throw {
    public struct Action {
        public static let dismissKey = -Int.randomIdentifier
        public static let closeKey = -Int.randomIdentifier
        
        public static let dismiss: Action = .init(key: dismissKey, style: .regular, title: "", icon: nil)
        public static func close(style: Style = .regular) -> Action {
            .init(key: closeKey, style: style, title: "ЗАТВОРИ", icon: nil)
        }
        
        public enum Style {
            case regular
            case suggestive
            case destructive
        }
        
        public let key: Int
        public let style: Style
        public let title: String
        public let icon: UIImage?
        
        public init(key: Int, style: Style = .regular, title: String, icon: UIImage? = nil) {
            self.key = key
            self.style = style
            self.title = title
            self.icon = icon
        }
    }
}

extension Fault.Throw: ReactiveCompatible { }
extension Reactive where Base == Fault.Throw {
    public var `catch`: Observable<Base.Action> {
        base.subject.asObservable()
    }
}

extension Fault: ReactiveCompatible { }

extension Reactive where Base == Fault {
    public static var `throw`: Observable<Base.Throw> {
        Base.thrower.asObservable()
    }
}

extension Error {
    @discardableResult
    public func `throw`(
        actions: [Fault.Throw.Action] = .init(),
        autodismiss: Bool = true,
        animated: Bool = true
    ) -> Fault.Throw {
        let t: Fault.Throw = .init(fault: fault, actions: actions, animated: animated, autodismiss: autodismiss)
        Fault.thrower.onNext(t)
        return t
    }
}
