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
    
    func register<T: UITableViewHeaderFooterView>(_ cellClass: T.Type) {
        register(cellClass, forHeaderFooterViewReuseIdentifier: cellClass.className)
    }

    func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type = T.self, for indexPath: IndexPath, addToSubviews flag: Bool = false) -> T {
        let cell: T =  Utils.castOrFatalError(dequeueReusableCell(withIdentifier: cellClass.className, for: indexPath))
        if flag, !cell.is(childOf: self) {
            addSubview(cell)
        }
        return cell
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type = T.self, for row: Int, addToSubviews flag: Bool = false) -> T {
        dequeueReusableCell(for: .init(row: row, section: 0), addToSubviews: flag)
    }
    
    func dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView>(_ cellClass: T.Type = T.self) -> T {
        let view: T =  Utils.castOrFatalError(dequeueReusableHeaderFooterView(withIdentifier: cellClass.className))
        return view
    }
    
    func reloadDataAndKeepOffset() {
        // stop scrolling
        setContentOffset(contentOffset, animated: false)
        
        // calculate the offset and reloadData
        let beforeContentSize = contentSize
        reloadData()
        layoutIfNeeded()
        let afterContentSize = contentSize
        
        // reset the contentOffset after data is updated
        let newOffset = CGPoint(
            x: contentOffset.x + (afterContentSize.width - beforeContentSize.width),
            y: contentOffset.y + (afterContentSize.height - beforeContentSize.height))
        setContentOffset(newOffset, animated: false)
    }
}

extension UITableViewCell {
    @objc
    open class func estimatedHeight(for size: CGSize) -> CGFloat {
        return UITableView.automaticDimension
    }
}
