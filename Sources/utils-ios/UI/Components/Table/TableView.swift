//
//  TableView.swift
//  
//
//  Created by Miroslav Yozov on 29.06.22.
//

import UIKit

extension Utils.UI {
    open class TableView: UITableView {
        /**
         An initializer that initializes the object with a NSCoder object.
        - Parameter aDecoder: A NSCoder instance.
        */
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            prepare()
        }

        public override init(frame: CGRect, style: UITableView.Style) {
            super.init(frame: frame, style: style)
            prepare()
        }

        /**
         An initializer that initializes the object.
         - Parameter frame: A CGRect defining the view's frame.
        */
        public convenience init(frame: CGRect) {
            self.init(frame: frame, style: .plain)
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
            contentScaleFactor = Screen.scale
            separatorStyle = .none
            
            // register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        }
    }
}
