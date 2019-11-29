//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 27.11.19.
//

import UIKit

import RxSwift
import RxCocoa

public extension Reactive where Base: UITableView {
    var willDisplayLastCell: ControlEvent<WillDisplayCellEvent> {
        let source = willDisplayCell.filter {
            $1.row == (self.base.numberOfRows(inSection: self.base.numberOfSections - 1) - 1)
        }
        return ControlEvent(events: source)
    }
}
