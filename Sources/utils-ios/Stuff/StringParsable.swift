//
//  StringParsable.swift
//  
//
//  Created by Miroslav Yozov on 1.11.19.
//

import Foundation

public protocol StringParsable {
    init(from text: String)
}

extension Int: StringParsable {
    public init(from text: String) {
        self = (text as NSString).integerValue
    }
}

extension Int64: StringParsable {
    public init(from text: String) {
        self = (text as NSString).longLongValue
    }
}

extension UInt: StringParsable {
    public init(from text: String) {
        self = UInt(Int(from: text))
    }
}

extension Bool: StringParsable {
    public init(from text: String) {
        self = (text as NSString).boolValue
    }
}

extension Float: StringParsable {
    public init(from text: String) {
        self = (text as NSString).floatValue
    }
}

extension Double: StringParsable {
    public init(from text: String) {
        self = (text as NSString).doubleValue
    }
}


