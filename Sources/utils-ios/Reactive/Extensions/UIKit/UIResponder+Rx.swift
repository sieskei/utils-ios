//
//  UIResponder+Rx.swift
//  
//
//  Created by Miroslav Yozov on 3.12.19.
//

import UIKit

import RxSwift
import RxCocoa

public extension Reactive where Base: UIResponder {
    var touchesBegan: ControlEvent<(Set<UITouch>, UIEvent?)> {
        return .init(events: methodInvoked(#selector(Base.touchesBegan(_:with:))).map {
            ($0.first as? Set<UITouch> ?? .init(), $0.last as? UIEvent)
        })
    }
    
    var touchesMoved: ControlEvent<(Set<UITouch>, UIEvent?)> {
        return .init(events: methodInvoked(#selector(Base.touchesMoved(_:with:))).map {
            ($0.first as? Set<UITouch> ?? .init(), $0.last as? UIEvent)
        })
    }
    
    var touchesEnded: ControlEvent<(Set<UITouch>, UIEvent?)> {
        return .init(events: methodInvoked(#selector(Base.touchesEnded(_:with:))).map {
            ($0.first as? Set<UITouch> ?? .init(), $0.last as? UIEvent)
        })
    }
    
    var touchesCancelled: ControlEvent<(Set<UITouch>, UIEvent?)> {
        return .init(events: methodInvoked(#selector(Base.touchesCancelled(_:with:))).map {
            ($0.first as? Set<UITouch> ?? .init(), $0.last as? UIEvent)
        })
    }
}

