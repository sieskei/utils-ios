//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 6.07.22.
//

import UIKit

extension Utils.UI {
    public struct Layout {
        /// A weak reference to the layoutable.
        public weak var layoutable: UtilsUILayoutable?
        
        public init(_ l: UtilsUILayoutable) {
            layoutable = l
        }
    }
}
