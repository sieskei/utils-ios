//
//  PrimitiveType.swift
//  
//
//  Created by Miroslav Yozov on 28.02.20.
//

import Foundation

public protocol PrimitiveType { }

extension Int    : PrimitiveType { }
extension Int64  : PrimitiveType { }
extension Int32  : PrimitiveType { }
extension Int16  : PrimitiveType { }
extension Int8   : PrimitiveType { }
extension UInt64 : PrimitiveType { }
extension UInt32 : PrimitiveType { }
extension UInt16 : PrimitiveType { }
extension UInt8  : PrimitiveType { }
extension Float  : PrimitiveType { }
extension Double : PrimitiveType { }
extension String : PrimitiveType { }
