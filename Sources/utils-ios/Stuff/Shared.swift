//
//  Shared.swift
//  
//
//  Created by Miroslav Yozov on 28.11.20.
//

import Foundation

public struct Shared<Base> { }

public protocol SharedCompatible {
    /// Extended type
    associatedtype InstanceBase
    
    /// Shared extensions.
    static var shared: Shared<InstanceBase>.Type { get }
}

extension SharedCompatible {
    /// Shared extensions.
    public static var shared: Shared<Self>.Type {
        return Shared<Self>.self
    }
}
