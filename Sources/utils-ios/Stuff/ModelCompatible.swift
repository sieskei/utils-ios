//
//  ModelCompatible.swift
//  
//
//  Created by Miroslav Yozov on 30.10.19.
//

import Foundation

@available(*, deprecated, message: "Use @Model instead.")
public protocol ModelCompatible {
    associatedtype M: Equatable
    var model: Model<M> { get set }
}
