//
//  UNUserNotificationCenter+Rx.swift
//  
//
//  Created by Miroslav Yozov on 3.08.22.
//

import UIKit
import RxSwift

extension Reactive where Base: UNUserNotificationCenter {
    public var settings: Single<UNNotificationSettings> {
        Single.create { [base] observer in
            base.getNotificationSettings {
                observer(.success($0))
            }
            return Disposables.create { }
        }
    }
    
    public var isAuthorized: Observable<Bool> {
        UIApplication.rx.didBecomeActive
            .asObservable()
            .flatMap { [base] _ -> Observable<Bool> in
                base.rx.settings
                    .asObservable()
                    .map { $0.authorizationStatus == .authorized }
            }
            .merge(with: settings
                    .asObservable()
                    .map{ $0.authorizationStatus == .authorized })
            .distinctUntilChanged()
    }
}
