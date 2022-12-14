//
//  UТViewController.swift
//  
//
//  Created by Miroslav Yozov on 5.04.22.
//

import UIKit

extension Utils.UI {
    open class ViewController: UIViewController {
        public convenience init() {
            self.init(nibName: nil, bundle: nil)
        }
        
        public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            initialize()
        }
        
        required public init?(coder: NSCoder) {
            super.init(coder: coder)
            initialize()
        }
        
        open override func viewDidLoad() {
            super.viewDidLoad()
            prepare()
        }
        
        open func initialize() { }
      
        /**
         Prepares the view instance when intialized. When subclassing,
         it is recommended to override the prepare method
         to initialize property values and other setup operations.
         The super.prepare method should always be called immediately
         when subclassing.
        */
        open func prepare() {
            view.clipsToBounds = true
            view.backgroundColor = .white
            view.contentScaleFactor = Screen.scale
        }
      
        open override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()
            layoutSubviews()
        }
      
        /**
         Calls the layout functions for the view heirarchy.
         To execute in the order of the layout chain, override this
         method. `layoutSubviews` should be called immediately, unless you
         have a certain need.
        */
        open func layoutSubviews() { }
    }
}
