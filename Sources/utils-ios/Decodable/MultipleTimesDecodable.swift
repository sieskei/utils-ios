//
//  MultipleTimesDecodable.swift
//  
//
//  Created by Miroslav Yozov on 30.10.19.
//

import Foundation

@available(*, deprecated, message: "Use Decodable & Redecodable instead.")
public protocol MultipleTimesDecodable: Decodable, Redecodable { }
