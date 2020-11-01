//
//  OptionsController+TableViewCell.swift
//  
//
//  Created by Miroslav Yozov on 31.10.20.
//

import UIKit
import Material
import RxSwift

extension OptionsController {
    public class TableViewCell: Material.TableViewCell {
        public class SeparatorView: View { }
        
        private let disposeBag = DisposeBag()
        
        private lazy var nameLabel: Label = {
            let l: Label = .init()
            rx.model.map { $0.name }.bind(to: l.rx.text).disposed(by: disposeBag)
            return l
        }()
        
        private lazy var separatorView: SeparatorView = {
            let v: SeparatorView = .init()
            v.backgroundColor = .black
            return v
        }()
        
        public override func prepare() {
            super.prepare()
            
            backgroundColor = .clear
            contentView.backgroundColor = .clear
            
            contentView.layout(separatorView)
                .left(16)
                .right(16)
                .bottom(8)
                .height(1)
            
            contentView.layout(nameLabel)
                .top(8)
                .left(24)
                .right(24)
                .bottom(separatorView.anchor.top, 8)
        }
    }
}

extension OptionsController.TableViewCell: RxModelCompatible {
    public typealias M = OptionsController.Action
}

fileprivate extension Model where M: OptionsController.Action {
    var name: String {
        map("--") { $0.name }
    }
}
