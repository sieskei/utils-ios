//
//  Utils+Tracking.swift
//  
//
//  Created by Miroslav Yozov on 15.04.21.
//

import Foundation
import AppTrackingTransparency
import RxSwift

extension Utils {
    public struct Tracking: ReactiveCompatible {
        @RxProperty
        fileprivate static var isRequestedProperty: Bool = {
            guard #available(iOS 14, *) else {
                return true
            }
            
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .authorized, .denied:
                return true
            case .notDetermined, .restricted:
                fallthrough
            @unknown default:
                ATTrackingManager.requestTrackingAuthorization { _ in
                    Tracking.isRequestedProperty = true
                }
                return false
            }
        }()
        
        public static var isRequested: Bool {
            isRequestedProperty
        }
    }
}

extension Reactive where Base == Utils.Tracking {
    public static var isRequested: Observable<Bool> {
        Base.$isRequestedProperty.value.asObservable()
    }
}
