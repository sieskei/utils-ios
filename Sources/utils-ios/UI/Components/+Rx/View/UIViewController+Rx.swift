//
//  UIViewController+Rx.swift
//  
//
//  Created by Miroslav Yozov on 24.01.20.
//

import UIKit

import RxCocoa
import RxSwift

public extension Reactive where Base: UIViewController {
    var viewDidLoad: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
        return ControlEvent(events: source)
    }

    var viewWillAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    var viewDidAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }

    var viewWillDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    var viewDidDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }

    var viewWillLayoutSubviews: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillLayoutSubviews)).map { _ in }
        return ControlEvent(events: source)
    }
    
    var viewDidLayoutSubviews: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidLayoutSubviews)).map { _ in }
        return ControlEvent(events: source)
    }

    var willMoveToParentViewController: ControlEvent<UIViewController?> {
        let source = self.methodInvoked(#selector(Base.willMove)).map { $0.first as? UIViewController }
        return ControlEvent(events: source)
    }
    
    var didMoveToParentViewController: ControlEvent<UIViewController?> {
        let source = self.methodInvoked(#selector(Base.didMove)).map { $0.first as? UIViewController }
        return ControlEvent(events: source)
    }
    
    var didRemoveFromParent: ControlEvent<Void> {
        let source = didMoveToParentViewController.filter { $0 == nil }.map { _ in }
        return ControlEvent(events: source)
    }

    var didReceiveMemoryWarning: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.didReceiveMemoryWarning)).map { _ in }
        return ControlEvent(events: source)
    }

    /// Rx observable, triggered when the ViewController appearance state changes (true if the View is being displayed, false otherwise)
    var isVisible: Observable<Bool> {
        let viewDidAppearObservable = self.base.rx.viewDidAppear.map { _ in true }
        let viewWillDisappearObservable = self.base.rx.viewWillDisappear.map { _ in false }
        return Observable<Bool>.merge(viewDidAppearObservable, viewWillDisappearObservable)
    }

    /// Rx observable, triggered when the ViewController is being dismissed
    var isDismissing: ControlEvent<Bool> {
        let source = self.sentMessage(#selector(Base.dismiss)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    var presented: Observable<UIViewController> {
        base.rx
            .methodInvoked(#selector(Base.viewDidAppear(_:)))
            .withUnretained(base)
            .map { $0.0 }
            .filter { $0.isMovingToParent || $0.isBeingPresented }
    }
    
    var dismissed: Observable<UIViewController> {
        base.rx
            .methodInvoked(#selector(Base.viewDidDisappear(_:)))
            .withUnretained(base)
            .map { $0.0 }
            .filter {
                var vc: UIViewController? = $0
                while let v = vc {
                    if v.isBeingDismissed || (v.isMovingFromParent && v.parent == nil) {
                        return true
                    }
                    vc = v.parent
                }
                return false
            }
    }
    
    func present<T: UIViewController>(_ viewControllerToPresent: T, animated flag: Bool) -> Observable<T> {
        .create({ [weak base] observer in
            if let base = base {
                base.present(viewControllerToPresent, animated: flag) {
                    observer.onNext((viewControllerToPresent))
                    observer.onCompleted()
                }
            } else {
                observer.onCompleted()
            }
            return Disposables.create { }
        })
    }
    
    func dismiss(animated flag: Bool) -> Observable<Void> {
        .create({ [weak base] observer in
            if let base = base {
                base.dismiss(animated: flag) {
                    observer.onNext(())
                    observer.onCompleted()
                }
            } else {
                observer.onCompleted()
            }
            return Disposables.create { }
        })
    }
}
