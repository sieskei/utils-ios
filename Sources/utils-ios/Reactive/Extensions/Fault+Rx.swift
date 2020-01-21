//
//  Fault+Rx.swift
//  
//
//  Created by Miroslav Yozov on 21.01.20.
//

import Foundation
import RxSwift

public enum ErrorDismissSource {
    public enum Style {
        case regular
        case suggestive
    }

    public typealias Action = (key: String, name: String, style: Style)

    case action(Action)
    case close
}

public typealias ErrorPresentEvent = (Fault, animated: Bool, completion: (() -> Void)?,
    dismissActions: [ErrorDismissSource.Action], dismissCompletion: ((ErrorDismissSource) -> Void)?)

extension Fault: ReactiveCompatible {
    fileprivate static let present: PublishSubject<ErrorPresentEvent> = {
        let subject: PublishSubject<ErrorPresentEvent> = .init()
        return subject
    }()
}

public extension Reactive where Base: Fault {
    static var present: Observable<ErrorPresentEvent> {
        return Fault.present.asObservable()
    }
}

public extension Error {
    func present(animated flag: Bool = true, completion: (() -> Void)? = nil,
                 dismissActions: [ErrorDismissSource.Action] = [],
                 dismissCompletion: ((ErrorDismissSource) -> Void)? = nil) {
        Fault.present.onNext((self.fault, flag, completion, dismissActions, dismissCompletion))
    }
}
