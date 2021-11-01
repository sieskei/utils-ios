//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 4.08.21.
//

import UIKit

fileprivate var WindowKey: UInt8 = 0

public protocol WindowPresentCompatible {
    var window: UIWindow { get }
    var windowLevel: UIWindow.Level { get }
    
    func windowPresent(animated: Bool, completion: (() -> Void)?)
    func windowDismiss(animated: Bool, completion: (() -> Void)?)
}

fileprivate class Window: UIWindow {
    class ViewController: UIViewController, DisposeContext {
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .blue
        }
        
        deinit {
            Utils.Log.debug("deinit", self)
        }
    }
    
    deinit {
        Utils.Log.debug("deinit", self)
    }
}

public extension WindowPresentCompatible {
    var window: UIWindow {
        Utils.AssociatedObject.get(base: self, key: &WindowKey, policy: .strong) {
            Window() ~> {
                $0.windowLevel = windowLevel
            }
        }
    }
    
    var windowLevel: UIWindow.Level {
        .normal
    }
}

public extension WindowPresentCompatible where Self: UIViewController {
    func windowPresent(animated: Bool, completion: (() -> Void)? = nil) {
        defer {
            window.makeKeyAndVisible()
        }
        
        let rootViewController: Window.ViewController = .init()
        window.rootViewController = rootViewController
        window.backgroundColor = .red
        
        
        
        // window.rootViewController?.present(self, animated: true)
        
//        if let root = window.rootViewController as? Window.Root {
//            root.rx.viewDidAppear
//                .subscribe(with: self, onNext: { this, _ in
//                    root.present(this, animated: true)
//                })
//                .disposed(by: root)
//        }
    }
    
    func windowDismiss(animated: Bool, completion: (() -> Void)? = nil) {
        defer {
            window.resignKey()
        }
        
        
        
    }
}
