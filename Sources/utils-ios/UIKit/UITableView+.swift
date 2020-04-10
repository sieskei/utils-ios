//
//  UITableView+.swift
//  
//
//  Created by Miroslav Yozov on 28.11.19.
//

import UIKit

public extension UITableView {
    func register<T: UITableViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: cellClass.className)
    }

    func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type = T.self, for indexPath: IndexPath, addToSubviews flag: Bool = false) -> T {
        let cell: T = dequeueReusableCell(withIdentifier: cellClass.className, for: indexPath) as! T
        if flag, !cell.is(childOf: self) {
            addSubview(cell)
        }
        return cell
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type = T.self, for row: Int, addToSubviews flag: Bool = false) -> T {
        return dequeueReusableCell(for: .init(row: row, section: 0), addToSubviews: flag)
    }
}
