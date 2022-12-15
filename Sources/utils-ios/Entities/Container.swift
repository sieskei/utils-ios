//
//  Container.swift
//  
//
//  Created by Miroslav Yozov on 5.11.19.
//

import Foundation

open class Container<Element: Decodable>: Decodable, RxRedecodable {
    open class var factory: Factory.Type {
        Factory.self
    }
    
    public var factory: Factory {
        Self.factory.init(self)
    }
    
    open private (set) var elements: [Element] = []
    
    public var count: Int {
        elements.count
    }
    
    public subscript(index: Int) -> Element? {
        guard index >= 0 && index < elements.count else { return nil }
        return elements[index]
    }
    
    public required init(from decoder: Decoder) throws {
        do {
            elements = try factory.elements(from: decoder, current: [])
        } catch (let error) {
            Utils.Log.warning(type(of: self).factory, "Decode elements fail.", error)
        }
    }
    
    public init(elements: [Element] = []) {
        self.elements = elements
    }
    
    public func decode(from decoder: Decoder) throws {
        do {
            switch decoder.decodeType {
            case .replace:
                elements = try factory.elements(from: decoder, current: elements)
            case .append:
                elements.append(contentsOf: try factory.elements(from: decoder, current: []))
            }
        } catch (let error) {
            Utils.Log.warning(type(of: self).factory, "Decode elements fail.", error)
        }
    }
    
    deinit {
        print(self, "deinit ...")
    }
}

// MARK: Default factory - init new `Element`.
extension Container {
    open class Factory {
        public let container: Container<Element>
        
        required public init(_ container: Container<Element>) {
            self.container = container
        }
        
        open func unkeyedContainer(from decoder: Decoder) throws -> UnkeyedDecodingContainer {
            try decoder.unkeyedContainer()
        }
        
        open func element(from container: inout UnkeyedDecodingContainer) throws -> Element {
            try container.decode(Element.self)
        }
        
        open func elements(from decoder: Decoder, current: [Element]) throws -> [Element] {
            var container: UnkeyedDecodingContainer = try unkeyedContainer(from: decoder)
            
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

extension Container where Element: Equatable {
    public func index(of element: Element) -> Int? {
        elements.firstIndex(where: { $0 == element })
    }
}
