//
//  MultipleTimesDecodable.swift
//  
//
//  Created by Miroslav Yozov on 30.10.19.
//

import Foundation

public protocol MultipleTimesDecodable:
    class,
    Decodable,
    Synchronized {
    func runDecode(from decoder: Decoder) throws
    func decode(from decoder: Decoder) throws
}

extension MultipleTimesDecodable {
    func runDecode(from decoder: Decoder) throws {
        try synchronized {
            try decode(from: decoder)
        }
    }
}
