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

    func dequeueReusableCell<T: UICollectionViewCell>(_ cellClass: T.Type = T.self, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: cellClass.className, for: indexPath) as! T
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(_ cellClass: T.Type = T.self, for row: Int) -> T {
        return dequeueReusableCell(for: .init(row: row, section: 0))
    }
}
