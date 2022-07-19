//
//  UITableView+Rx.swift
//  
//
//  Created by Miroslav Yozov on 27.11.19.
//

import UIKit

import RxSwift
import RxCocoa

public extension Reactive where Base: UITableView {
    var willDisplayLastCell: ControlEvent<WillDisplayCellEvent> {
        let source = willDisplayCell.filter { [weak base = self.base] in
            guard let base = base else {
                return false
            }
            return $1.row == (base.numberOfRows(inSection: base.numberOfSections - 1) - 1)
        }
        return ControlEvent(events: source)
    }
}
