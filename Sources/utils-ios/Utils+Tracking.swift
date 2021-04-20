//
//  Utils+Tracking.swift
//  
//
//  Created by Miroslav Yozov on 15.04.21.
//

import Foundation
import AppTrackingTransparency
import RxSwift

public protocol TrackingItem {
    typealias Parameters = [String: Any]
    var params: Parameters { get }
}

public protocol TrackingPlatform {
    func initialize()
    func track(item: TrackingItem)
}

extension Utils {
    public struct Tracking: ReactiveCompatible {
        private enum Initialized {
            case `true`
            case `false`
            case running
            
            var asBool: Bool { self == .true }
            var isRunning: Bool { self == .running }
        }
        
        private static let disposeBag: DisposeBag = .init()
        
        @RxProperty
        private static var initialized: Initialized = .false
        
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
        
        private static var trackQueue: Notifier<TrackingItem> = {
            let queue: Notifier<TrackingItem> = .init()
            
            queue
                .pausableBuffered($initialized.value.map { $0.asBool }, limit: nil)
                .subscribe(onNext: { i in
                    platforms.forEach {
                        $0.track(item: i)
                    }
                }).disposed(by: disposeBag)
            
            return queue
        }()
        
        private static var platforms: [TrackingPlatform] = []
        
        public static var isRequested: Bool {
            isRequestedProperty
        }
        
        public static func register(platforms: TrackingPlatform...) {
            guard !initialized.asBool else {
                Utils.Log.error("Tracking platform must be register before initialization.")
                return
            }
            
            platforms.forEach {
                Tracking.platforms.append($0)
            }
        }
        
        public static func initialize() {
            guard !initialized.asBool else {
                Utils.Log.warning("Already initialized.")
                return
            }
            
            guard !initialized.isRunning else {
                return
            }
            
            rx.isRequested
                .do(onCompleted: {
                    platforms.forEach {
                        $0.initialize()
                    }
                    initialized = .true
                }, onSubscribe: {
                    initialized = .running
                })
                .subscribe()
                .disposed(by: disposeBag)
        }
        
        public static func track(item: TrackingItem) {
            trackQueue.notify(item)
        }
    }
}

extension Reactive where Base == Utils.Tracking {
    public static var isRequested: Observable<Bool> {
        Base.$isRequestedProperty.value
            .asObservable()
            .skip(while: { !$0 })
            .take(1)
            .observe(on: MainScheduler.instance)
    }
}
