//
//  OptionsController+TableViewCell.swift
//  
//
//  Created by Miroslav Yozov on 31.10.20.
//

import UIKit
import RxSwift

extension Utils.UI.OptionsController {
    public class TableViewCell: Utils.UI.TableViewCell {
        public class SeparatorView: Utils.UI.View { }
        
        private let disposeBag = DisposeBag()
        
        private lazy var nameLabel: Utils.UI.Label = {
            let l: Utils.UI.Label = .init()
            $action.value.map { $0?.name ?? "---" }.bind(to: l.rx.text).disposed(by: disposeBag)
            return l
        }()
        
        private lazy var separatorView: SeparatorView = {
            let v: SeparatorView = .init()
            v.backgroundColor = .black
            return v
        }()
        
        @RxProperty
        public var action: Utils.UI.OptionsController.Action?
        
        public override func prepare() {
            super.prepare()
            
            backgroundColor = .clear
            contentView.backgroundColor = .clear
            
            contentView.anchor(subview: separatorView) {
                $1.left == $0.left + 16
                $1.right == $0.right + 16
                $1.bottom == $0.bottom + 8
                $1.height == 1
            }
            
            contentView.anchor(subview: nameLabel) {
                $1.left == $0.left + 24
                $1.right == $0.right + 24
                $1.top == $0.top + 8
                $1.bottom == separatorView.topAnchor + 8
            }
        }
    }
}
