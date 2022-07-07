//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 6.07.22.
//

import Foundation

extension Utils.UI.Layout {
    public struct Anchor {
        /// A weak reference to the constraintable.
        public weak var layoutable: UtilsUILayoutable?

        /// An array of LayoutAttribute for the view.
        public let attributes: [Utils.UI.Layout.Attribute]

        /**
        An initializer taking constraintable and anchor attributes.
        - Parameter layoutable: A Layoutable.
        - Parameter attributes: An array of Layout Atrribute.
        */
        public init(layoutable l : UtilsUILayoutable?, attributes attrs: [Utils.UI.Layout.Attribute] = []) {
            layoutable = l
            attributes = attrs
        }
    }
}
