//
//  Alamofire+.swift
//  
//
//  Created by Miroslav Yozov on 30.11.20.
//

import Foundation
import Alamofire

extension AFError: ErrorContainer {
    public var errorOrSelf: Error {
        underlyingError ?? self
    }
}
