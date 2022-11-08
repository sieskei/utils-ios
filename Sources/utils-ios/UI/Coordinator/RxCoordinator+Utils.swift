//
//  RxCoordinator+Utils.swift
//  
//
//  Created by Miroslav Yozov on 8.11.22.
//

import UIKit
import RxSwift

extension RxCoordinator {
    public func controller<T>(_ controller: UIViewController, present coordinator: RxCoordinator<T>, animated: Bool = true) -> Observable<T> {
        connect(to: coordinator)
            .`do`(with: self, onNext: { this, lifecycle in
                switch lifecycle {
                case .present(let vc):
                    controller.present(vc, animated: true)
                case .dismiss(_, let trigger):
                    if !trigger.isDisappear {
                        controller.dismiss(animated: true)
                    }
                default:
                    break
                }
            })
            .filterMap {
                switch $0 {
                case .event(let e):
                    return .map(e)
                default:
                    return .ignore
                }
            }
    }
    
    public func navigation<T>(_ controller: UINavigationController, push coordinator: RxCoordinator<T>, animated: Bool = true) -> Observable<T> {
        connect(to: coordinator)
            .`do`(with: self, onNext: { this, lifecycle in
                switch lifecycle {
                case .present(let vc):
                    if controller.viewControllers.isEmpty {
                        controller.setViewControllers([vc], animated: false)
                    } else {
                        controller.pushViewController(vc, animated: animated)
                    }
                case .dismiss(let vc, let trigger):
                    if !trigger.isDisappear {
                        controller.popToViewController(vc, behavior: .exclusive, animated: animated)
                    }
                default:
                    break
                }
            })
            .filterMap {
                switch $0 {
                case .event(let e):
                    return .map(e)
                default:
                    return .ignore
                }
            }
    }
}
