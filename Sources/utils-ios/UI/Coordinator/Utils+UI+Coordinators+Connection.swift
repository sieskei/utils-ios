//
//  Utils+UI+Coordinators+Connection.swift
//  
//
//  Created by Miroslav Yozov on 24.11.22.
//

import Foundation
import RxSwift

extension Utils.UI.Coordinators {
    class Connection {
        enum State: Equatable {
            enum SuspendTrigger: Int {
                case `self`
                case parent
            }
            
            case established
            case suspended(trigger: SuspendTrigger = .self)
        }
        
        var state: Value<State>
        var untilDismiss: Bool
        
        var isEstablished: Bool {
            switch state.value {
            case .established:
                return true
            case .suspended:
                return false
            }
        }
        
        var isSuspended: Bool {
            !isEstablished
        }
        
        init(startImmediately: Bool = true, untilDismiss: Bool = true) {
            self.state = .init(startImmediately ? .established : .suspended())
            self.untilDismiss = untilDismiss
        }
    }
}

extension Utils.UI.Coordinators.Connection: ReactiveCompatible { }
