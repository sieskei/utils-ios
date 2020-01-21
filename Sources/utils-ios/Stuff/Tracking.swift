//
//  Tracking.swift
//  
//
//  Created by Miroslav Yozov on 21.01.20.
//

import Foundation

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
    private static var instances: [TrackCompatible] = {
        return []
    }()
    
    public static func initialize() {
        instances.forEach {
            $0.initialize()
        }
    }
    
    public static func track(meta: TrackCompatibleEvent) {
        var params = meta.params
        params["event"] = meta.eventName
        
        instances.forEach {
            $0.track(params: params)
        }
    }
}
