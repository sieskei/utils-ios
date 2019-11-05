//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 5.11.19.
//

import Foundation

class Container<Element: Decodable>: MultipleTimesDecodable {
    class var factory: Factory.Type {
        return Factory.self
    }
    
    private (set) var elements: [Element]
    
    var count: Int {
        return elements.count
    }
    
    subscript(index: Int) -> Element? {
        guard index >= 0 && index < elements.count else { return nil }
        return elements[index]
    }
    
    required init(from decoder: Decoder) throws {
        let factory = type(of: self).factory
        self.elements = try factory.elements(from: decoder, current: [])
    }
    
    init(elements: [Element] = []) {
        self.elements = elements
    }
    
    func decode(from decoder: Decoder) throws {
        
    }
    
    deinit {
        print(self, "deinit ...")
    }
}

extension Container {
    class Factory {
        class func unkeyedContainer(from decoder: Decoder) throws -> UnkeyedDecodingContainer {
            return decoder.unkeyedContainer()
        }
        
        class func elements(from decoder: Decoder, current: [Element]) throws -> [Element] {
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
