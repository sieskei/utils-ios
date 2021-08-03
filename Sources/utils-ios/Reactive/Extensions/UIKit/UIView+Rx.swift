//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 23.07.21.
//

import UIKit

import RxSwift
import RxCocoa

public extension Reactive where Base: UIView {
    var bounds: Observable<CGRect> {
        observeWeakly(CGRect.self, #keyPath(UIView.bounds), options: [.new, .initial])
            .unwrap()
    }
}
