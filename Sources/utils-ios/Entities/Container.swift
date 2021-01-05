//
//  Container.swift
//  
//
//  Created by Miroslav Yozov on 5.11.19.
//

import Foundation

open class Container<Element: Decodable>: RxMultipleTimesDecodable {
    open class var factory: Factory.Type {
        return Factory.self
    }
    
    open private (set) var elements: [Element]
    
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
extension Container {
    open class Factory {
        // called from init
        open class func items(from decoder: Decoder) throws -> [Element] {
            return []
        }
        
        // called from decode
        open class func items(from decoder: Decoder, for container: Container) throws -> [Element] {
            return []
        }
        
        
        
        
        
        
        open class func unkeyedContainer(from decoder: Decoder) throws -> UnkeyedDecodingContainer {
            return try decoder.unkeyedContainer()
        }
        
        open class func element(from container: inout UnkeyedDecodingContainer) throws -> Element {
            return try container.decode(Element.self)
        }
        
        open class func elements(from decoder: Decoder, current: [Element]) throws -> [Element] {
            var container: UnkeyedDecodingContainer
            do {
                container = try unkeyedContainer(from: decoder)
            } catch (let error) {
                Utils.Log.error("Container.Factory: missing 'Unkeyed Container'.", error)
                throw error
            }
            
            var elements = [Element]()
            while !container.isAtEnd {
                do {
                    let e = try element(from: &container)
                    elements.append(e)
                } catch (let error) {
                    Utils.Log.error("Container.Factory: unable to decode element.", error)
                }
            }
            return elements
        }
    }
}

// MARK: Default equal implementation by identity.
extension Container: IdentityEquatable { }
