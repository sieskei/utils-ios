//
//  RxMultipleTimesDecodable.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation
import RxSwift

@available(*, deprecated, message: "Use Decodable & RxRedecodable instead.")
public protocol RxMultipleTimesDecodable: MultipleTimesDecodable, RxRedecodable { }
