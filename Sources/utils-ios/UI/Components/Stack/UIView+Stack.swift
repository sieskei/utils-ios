//
//  UIView+Stack.swift
//  
//
//  Created by Miroslav Yozov on 29.06.23.
//

import UIKit

internal extension UIView {
    static func stack(elements elems: [Element],
                      direction: Direction = .vertical,
                      frame: UtilsUIAnchorsCompatible,
                      content: UtilsUIAnchorsCompatible,
                      parent: UIView) {

        elems.forEach { e in
            e.view.translatesAutoresizingMaskIntoConstraints = false
            parent.addSubview(e.view)

            switch direction {
            case .vertical:
                e.view.leftAnchor == content.leftAnchor + e.insets.left
                e.view.rightAnchor == content.rightAnchor - e.insets.right
                e.view.widthAnchor == frame.widthAnchor - e.insets.horizontal
            case .horizontal:
                e.view.topAnchor == content.topAnchor + e.insets.top
                e.view.bottomAnchor == content.bottomAnchor - e.insets.bottom
                e.view.heightAnchor == frame.heightAnchor - e.insets.vertical
            }
        }

        switch elems.count {
        case 1:
            let e = elems[0]
            switch direction {
            case .vertical:
                e.view.topAnchor == content.topAnchor + e.insets.top
                e.view.bottomAnchor == content.bottomAnchor - e.insets.bottom
            case .horizontal:
                e.view.leftAnchor == content.leftAnchor + e.insets.left
                e.view.rightAnchor == content.rightAnchor - e.insets.right
            }
        default:
            let f = elems[0] // first
            let l = elems[elems.count - 1] // last

            switch direction {
            case .vertical:
                f.view.topAnchor == content.topAnchor + f.insets.top

                // middle
                if elems.count > 2 {
                    for i in 1...elems.count - 2 {
                        let s = elems[i].insets.top + elems[i - 1].insets.bottom // spacing
                        elems[i].view.topAnchor == elems[i - 1].view.bottomAnchor + s
                    }
                }

                let ls = l.insets.top + elems[elems.count - 2].insets.bottom // spacing
                l.view.topAnchor == elems[elems.count - 2].view.bottomAnchor + ls
                l.view.bottomAnchor == content.bottomAnchor - l.insets.bottom
            case .horizontal:
                f.view.leftAnchor == content.leftAnchor + f.insets.left

                // middle
                if elems.count > 2 {
                    for i in 1...elems.count - 2 {
                        let s = elems[i].insets.left + elems[i - 1].insets.right // spacing
                        elems[i].view.leftAnchor == elems[i - 1].view.rightAnchor + s
                    }
                }

                let ls = l.insets.left + elems[elems.count - 2].insets.right // spacing
                l.view.leftAnchor == elems[elems.count - 2].view.rightAnchor + ls
                l.view.rightAnchor == content.rightAnchor - l.insets.right
            }
        }
    }
}

// MARK: UtilsUIStackCompatible
public extension UtilsUIStackCompatible where Self: UIView {
    init(views: [UIView], insets: UIEdgeInsets = .zero) {
        self.init(elements: views.map { ($0, insets) })
    }
    
    init(elements: [UIView.Element], direction: UIView.Direction = .vertical) {
        self.init(frame: .zero)
        stack(elements: elements, direction: direction)
    }
    
    func stack(elements elems: [Element], direction: UIView.Direction = .vertical) {
        UIView.stack(elements: elems, direction: direction, frame: self, content: self, parent: self)
    }
}
