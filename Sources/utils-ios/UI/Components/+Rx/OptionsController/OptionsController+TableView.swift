//
//  OptionsController+TableView.swift
//  
//
//  Created by Miroslav Yozov on 31.10.20.
//

import UIKit

extension Utils.UI.OptionsController {
    public class TableView: Utils.UI.NoScrollTableView {
        public override func prepare() {
            contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
            
            super.prepare()
            
            backgroundColor = .clear
            
            rowHeight = UITableView.automaticDimension
            estimatedRowHeight = 44
            
            register(Utils.UI.OptionsController.TableViewCell.self)
        }
    }
}


