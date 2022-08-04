//
//  UNUserNotificationCenter+Rx.swift
//  
//
//  Created by Miroslav Yozov on 3.08.22.
//

import UIKit
import RxSwift

extension Reactive where Base: UNUserNotificationCenter {
    public var isAuthorized: Observable<Bool> {
        UIApplication.rx.didBecomeActive
            .asObservable()
            .flatMap { [base] _ -> Observable<Bool> in
                Observable.create { observer in
                    base.getNotificationSettings(completionHandler: { (settings: UNNotificationSettings) in
                        observer.onNext(settings.authorizationStatus == .authorized)
                    })
                    return Disposables.create()
                }
           }
    }
}
