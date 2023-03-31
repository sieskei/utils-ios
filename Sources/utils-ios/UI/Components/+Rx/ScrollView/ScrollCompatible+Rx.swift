//
//  ScrollCompatible+Rx.swift
//  
//
//  Created by Miroslav Yozov on 19.07.22.
//

import UIKit
import RxSwift

extension Reactive where Base: UtilsUIScrollCompatible {
    public var scrollDimensions: Observable<CGSize> {
        let size: Observable<CGSize> = observe(CGSize.self, base.scrollSizeKeyPath)
            .unwrap()
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
        
        let insets: Observable<UIEdgeInsets> = observe(UIEdgeInsets.self, base.scrollInsetKeyPath)
            .unwrap()
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
        
        return Observable.combineLatest(size, insets)
            .map { size, insets in
                .init(width: size.width + insets.horizontal, height: size.height + insets.vertical)
            }
    }
}
