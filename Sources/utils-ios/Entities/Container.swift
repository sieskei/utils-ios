//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 5.11.19.
//

import Foundation

public class Container<Element: Decodable> {
    class var factory: Factory.Type {
        return Factory.self
    }
    
    public private (set) var elements: [Element]
    
    public var count: Int {
        return elements.count
    }
    
    public subscript(index: Int) -> Element? {
        guard index >= 0 && index < elements.count else { return nil }
        return elements[index]
    }
    
    public required init(from decoder: Decoder) throws {
        let factory = type(of: self).factory
        self.elements = try factory.elements(from: decoder, current: [])
    }
    
    public init(elements: [Element] = []) {
        self.elements = elements
    }
    
    public func decode(from decoder: Decoder) throws {
        let factory = type(of: self).factory
        switch decoder.decodeType {
        case .replace:
            elements = try factory.elements(from: decoder, current: elements)
        case .append:
            elements.append(contentsOf: try factory.elements(from: decoder, current: []))
        }
    }
    
    deinit {
        print(self, "deinit ...")
    }
}

// MARK: Default factory - init new `Element`.
public extension Container {
    class Factory {
        public class func unkeyedContainer(from decoder: Decoder) throws -> UnkeyedDecodingContainer {
            return try decoder.unkeyedContainer()
        }
        
        public class func elements(from decoder: Decoder, current: [Element]) throws -> [Element] {
            guard var container = try? unkeyedContainer(from: decoder) else {
                return []
            }
            
            var elements = [Element]()
            while !container.isAtEnd {
                do {
                    let element = try container.decode(Element.self)
                    elements.append(element)
                } catch { }
            }
            
            return elements
        }
    }
}
