//
//  TabItem+Rx.swift
//  
//
//  Created by Miroslav Yozov on 29.11.19.
//

import UIKit

import Material

import RxSwift
import RxCocoa

public extension Reactive where Base: TabItem {
    /// Bindable sink for `title` property.
    var title: Binder<String?> {
        return Binder(self.base) { item, title in
            item.title = title
        }
    }
}
