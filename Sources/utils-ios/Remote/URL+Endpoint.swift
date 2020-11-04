//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 1.11.20.
//

import Foundation

extension URL: Endpoint {
    public func asURLRequest() throws -> URLRequest {
        .init(url: self)
    }
}
