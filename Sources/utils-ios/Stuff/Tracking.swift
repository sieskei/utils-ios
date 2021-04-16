//
//  Tracking.swift
//  
//
//  Created by Miroslav Yozov on 21.01.20.
//

import Foundation
import RxSwift

public protocol TrackCompatibleSource {
    var trackingScreen: TrackCompatibleItem { get }
}

public protocol TrackCompatibleItem {
    typealias Parameters = [String: Any]
    
    var params: Parameters { get }
}

public protocol TrackCompatibleEvent: TrackCompatibleItem {
    var eventName: String { get }
}

public protocol TrackCompatible {
    func initialize()
    func track(params: TrackCompatibleItem.Parameters)
}

public struct TrackSystems {
    private static let disposeBag: DisposeBag = .init()
    
    @RxProperty
    private static var initialized: Bool = false
    
    private static var trackQueue: Notifier<TrackCompatibleEvent> = {
        let queue: Notifier<TrackCompatibleEvent> = .init()
        
        let pauser = Observable.combineLatest($initialized.value.asObservable(), Utils.Tracking.rx.isRequested.observe(on: MainScheduler.instance))
            .map { $0 && $1 }
        
        queue
            .pausableBuffered(pauser, limit: nil)
            .subscribe(onNext: { meta in
                var params = meta.params
                params["event"] = meta.eventName
                
                TrackSystems.instances.forEach {
                    $0.track(params: params)
                }
            }).disposed(by: disposeBag)
        
        return queue
    }()
    
    public static var instances: [TrackCompatible] = []
    
    public static func initialize() {
        if !initialized {
            instances.forEach { $0.initialize() }
            initialized = true
        }
    }
    
    public static func track(meta: TrackCompatibleEvent) {
        trackQueue.notify(meta)
    }
}
