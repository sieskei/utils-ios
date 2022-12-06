//
//  Utils+UI+Coordinators+Types.swift
//  
//
//  Created by Miroslav Yozov on 24.11.22.
//

import Foundation

internal protocol UtilsUICoordinatorsConnectable: AnyObject {
    var connection: Utils.UI.Coordinators.Connection? { get }
    
    var connectionsToSuspend: [Utils.UI.Coordinators.Connection] { get }
    var connectionsToBeResume: [Utils.UI.Coordinators.Connection] { get }
}
