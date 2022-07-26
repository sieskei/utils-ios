//
//  CollectionView.swift
//  
//
//  Created by Miroslav Yozov on 25.07.22.
//

import UIKit

extension Utils.UI {
    open class CollectionView: UICollectionView {
        /**
        An initializer that initializes the object with a NSCoder object.
        - Parameter aDecoder: A NSCoder instance.
        */
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            prepare()
        }
      
        /**
        An initializer that initializes the object.
        - Parameter frame: A CGRect defining the view's frame.
        - Parameter collectionViewLayout: A UICollectionViewLayout reference.
        */
        public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
            super.init(frame: frame, collectionViewLayout: layout)
            prepare()
        }
      
        /**
        An initializer that initializes the object.
        - Parameter collectionViewLayout: A UICollectionViewLayout reference.
        */
        public init(collectionViewLayout layout: UICollectionViewLayout) {
            super.init(frame: .zero, collectionViewLayout: layout)
            prepare()
        }

        /**
        Prepares the view instance when intialized. When subclassing,
        it is recommended to override the prepare method
        to initialize property values and other setup operations.
        The super.prepare method should always be called immediately
        when subclassing.
        */
        open func prepare() {
            backgroundColor = .white
            contentScaleFactor = Utils.UI.Screen.scale
        }
    }
}


