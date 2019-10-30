//
//  UIViewController+Base.swift
//  sinoptik-ios
//
//  Created by Miroslav Yozov on 26.03.19.
//  Copyright © 2019 Net Info. All rights reserved.
//

import UIKit

protocol BaseViewControllerType where Self: UIViewController {
    var isFromNib: Bool { get }
    func initialize()
}

class BaseViewController: UIViewController, BaseViewControllerType {
    private var initialized: Bool = false
    let isFromNib: Bool
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.isFromNib = true
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.isFromNib = true
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if isFromNib, !initialized {
            initialize()
        }
    }
    
    func initialize() {
        self.initialized = true
    }
}

class BaseNavigationConroller: UINavigationController, BaseViewControllerType {
    private var initialized: Bool = false
    let isFromNib: Bool
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.isFromNib = true
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.isFromNib = true
        super.init(coder: aDecoder)
    }
    
    override init(rootViewController: UIViewController) {
        self.isFromNib = false
        super.init(rootViewController: rootViewController)
        self.initialize()
    }
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        self.isFromNib = false
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        self.initialize()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if isFromNib, !initialized {
            initialize()
        }
    }
    
    func initialize() {
        self.initialized = true
    }
}
