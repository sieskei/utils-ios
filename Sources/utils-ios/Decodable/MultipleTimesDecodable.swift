//
//  MultipleTimesDecodable.swift
//  
//
//  Created by Miroslav Yozov on 30.10.19.
//

import Foundation

public protocol MultipleTimesDecodable: Decodable, Synchronized {
    func decode(from decoder: Decoder) throws
}






