//
//  OptionsController+TableView.swift
//  
//
//  Created by Miroslav Yozov on 31.10.20.
//

import UIKit
import Material

extension OptionsController {
    public class TableView: Material.TableView {
        override public var contentInset: UIEdgeInsets {
            didSet {
                let v = contentInset.top + contentInset.bottom
                let ov = oldValue.top + oldValue.bottom
                if v != ov {
                    layout.height(contentSize.height + v)
                }
            }
        }
        
        override public var contentSize: CGSize {
            didSet  {
                if contentSize.height != oldValue.height {
                    layout.height(contentSize.height + contentInset.top + contentInset.bottom)
                }
            }
        }
        
        public override func prepare() {
            super.prepare()
            
            bounces = false
            backgroundColor = .clear
            
            rowHeight = UITableView.automaticDimension
            estimatedRowHeight = 44
            
            contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
            
            register(OptionsController.TableViewCell.self)
            layout.height(contentSize.height + contentInset.top + contentInset.bottom).priority(.defaultHigh)
        }
    }
}


