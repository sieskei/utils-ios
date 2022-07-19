//
//  ScrollCompatible+Rx.swift
//  
//
//  Created by Miroslav Yozov on 19.07.22.
//

import UIKit
import RxSwift

extension Reactive where Base: UtilsUIScrollCompatible {
    public var scrollSize: Observable<CGSize> {
        observe(CGSize.self, base.scrollSizeKeyPath)
            .unwrap()
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
    }
}
