//
//  UIViewController+Base.swift
//  sinoptik-ios
//
//  Created by Miroslav Yozov on 26.03.19.
//  Copyright © 2019 Net Info. All rights reserved.
//

import UIKit

public protocol BaseViewControllerType where Self: UIViewController {
    var isFromNib: Bool { get }
    func initialize()
}

public class BaseViewController: UIViewController, BaseViewControllerType {
    private var initialized: Bool = false
    public let isFromNib: Bool
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.isFromNib = true
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.isFromNib = true
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        if isFromNib, !initialized {
            initialize()
        }
    }
    
    public func initialize() {
        self.initialized = true
    }
}

public class BaseNavigationConroller: UINavigationController, BaseViewControllerType {
    private var initialized: Bool = false
    public let isFromNib: Bool
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.isFromNib = true
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.isFromNib = true
        super.init(coder: aDecoder)
    }
    
    public override init(rootViewController: UIViewController) {
        self.isFromNib = false
        super.init(rootViewController: rootViewController)
        self.initialize()
    }
    
    public override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        self.isFromNib = false
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        self.initialize()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        if isFromNib, !initialized {
            initialize()
        }
    }
    
    public func initialize() {
        self.initialized = true
    }
}
