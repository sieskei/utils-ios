//
//  UITableView+.swift
//  
//
//  Created by Miroslav Yozov on 28.11.19.
//

import UIKit

public extension UITableView {
    func register<T: UITableViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: cellClass.nibName)
    }

    func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type = T.self, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: cellClass.nibName, for: indexPath) as! T
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type = T.self, for row: Int) -> T {
        return dequeueReusableCell(for: .init(row: row, section: 1))
    }
}
