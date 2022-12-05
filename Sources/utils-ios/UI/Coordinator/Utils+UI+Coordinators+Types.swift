//
//  Utils+UI+Coordinators+Types.swift
//  
//
//  Created by Miroslav Yozov on 24.11.22.
//

import Foundation

internal protocol UtilsUICoordinatorsConnectable: AnyObject {
    var connection: Utils.UI.Coordinators.Connection? { get }
    var flatConnections: [Utils.UI.Coordinators.Connection] { get }
}
