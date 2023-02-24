//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 24.02.23.
//

import Foundation
import RxSwift

public enum Buffer<Element> {
    case buffer(buffer: [RxSwift.Event<Element>] = [])
    case passthrough(PublishSubject<Element>)
    
    public mutating func push(_ event: RxSwift.Event<Element>) {
        switch self {
        case .buffer(let buffer):
            self = .buffer(buffer: buffer + [event])
        case .passthrough(let obsever):
            obsever.on(event)
        }
    }
    
    public mutating func flush(to observer: PublishSubject<Element>) {
        switch self {
        case .buffer(let buffer):
            buffer.forEach { observer.on($0) }
            fallthrough
        case .passthrough:
            self = .passthrough(observer)
        }
    }
}
