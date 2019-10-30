//
//  UIView+Nib.swift
//  sinoptik-ios
//
//  Created by Miroslav Yozov on 25.03.19.
//  Copyright © 2019 Net Info. All rights reserved.
//

import UIKit

public protocol BaseViewType where Self: UIView {
    var isFromNib: Bool { get }
    func initialize()
}

public class BaseView: UIView, BaseViewType {
    private var initialized: Bool = false
    public let isFromNib: Bool
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        self.isFromNib = false
        super.init(frame: frame)
        self.initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.isFromNib = true
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        if isFromNib, !initialized {
            initialize()
        }
    }
    
    public func initialize() {
        initialized = true
    }
}

class BaseTableView: UITableView, BaseViewType {
    private var initialized: Bool = false
    let isFromNib: Bool
    
    convenience init() {
        self.init(frame: .zero, style: .plain)
    }
    
    convenience init(frame: CGRect) {
        self.init(frame: frame, style: .plain)
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        self.isFromNib = false
        super.init(frame: frame, style: style)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.isFromNib = true
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if isFromNib, !initialized {
            initialize()
        }
    }
    
    func initialize() {
        initialized = true
    }
}

class BaseCollectionView: UICollectionView, BaseViewType {
    private var initialized: Bool = false
    let isFromNib: Bool
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        self.isFromNib = false
        super.init(frame: frame, collectionViewLayout: layout)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.isFromNib = true
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if isFromNib, !initialized {
            initialize()
        }
    }
    
    func initialize() {
        initialized = true
    }
}

class BaseTableViewCell: UITableViewCell, BaseViewType {
    private var initialized: Bool = false
    let isFromNib: Bool
    
    override var backgroundColor: UIColor? {
        didSet {
            contentView.backgroundColor = backgroundColor
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.isFromNib = false
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.isFromNib = true
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if isFromNib, !initialized {
            initialize()
        }
    }
    
    func initialize() {
        initialized = true
    }
}

class BaseColllectionViewCell: UICollectionViewCell, BaseViewType {
    private var initialized: Bool = false
    let isFromNib: Bool
    
    override var backgroundColor: UIColor? {
        didSet {
            contentView.backgroundColor = backgroundColor
        }
    }
    
    override init(frame: CGRect) {
        self.isFromNib = false
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.isFromNib = true
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if isFromNib, !initialized {
            initialize()
        }
    }
    
    func initialize() {
        initialized = true
    }
}

