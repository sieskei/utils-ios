//
//  UICollectionView+.swift
//  
//
//  Created by Miroslav Yozov on 3.01.20.
//

import UIKit

public extension UICollectionView {
    func register<T: UICollectionViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellWithReuseIdentifier: cellClass.className)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(_ cellClass: T.Type = T.self, for indexPath: IndexPath, addToSubviews flag: Bool = false) -> T {
        let cell: T = dequeueReusableCell(withReuseIdentifier: cellClass.className, for: indexPath) as! T
        if flag, !cell.is(childOf: self) {
            addSubview(cell)
        }
        return cell
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(_ cellClass: T.Type = T.self, for row: Int, addToSubviews flag: Bool = false) -> T {
        return dequeueReusableCell(for: .init(row: row, section: 0), addToSubviews: flag)
    }
}
