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
//        override func loadView() {
//            view = PassthroughView()
//        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .clear
        }
        
        deinit {
            Utils.Log.debug("deinit", self)
        }
    }
    
//    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        let view = super.hitTest(point, with: event)
//        return view == self ? nil : view
//    }
    
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
        window.backgroundColor = .clear
        
        
        rootViewController.rx.viewDidAppear
            .subscribe(with: self, onNext: { this, _ in
                rootViewController.present(this, animated: true)
            })
            .disposed(by: rootViewController)
    }
    
    func windowDismiss(animated: Bool, completion: (() -> Void)? = nil) {
        defer {
            window.resignKey()
        }
        
        
        
    }
}
