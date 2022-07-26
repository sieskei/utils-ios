//
//  Separator.swift
//  
//
//  Created by Miroslav Yozov on 25.07.22.
//

import UIKit

extension Utils.UI {
    public class Separator {
        /// A reference to the UIView.
        internal weak var view: UIView?
        
        /// A reference to the divider UIView.
        internal var line: UIView?
        
        /// A reference to the height.
        public var thickness: CGFloat {
            didSet {
                layout()
            }
        }
        
        /// A reference to EdgeInsets.
        public var contentEdgeInsets: UIEdgeInsets = .zero {
            didSet {
                layout()
            }
        }
        
        /// A UIColor.
        public var color: UIColor? {
            get {
                return line?.backgroundColor
            }
            set(value) {
                guard let v = value else {
                    line?.removeFromSuperview()
                    line = nil
                    return
                }
                
                let l: UIView
                if line == nil, let v = view {
                    l = .init()
                    l.layer.zPosition = 5000
                    v.addSubview(l)
                    v.bringSubviewToFront(l)
                    line = l
                    layout()
                } else {
                    l = line!
                }
                
                l.backgroundColor = v
            }
        }
        
        /// A reference to the dividerAlignment.
        public var alignment: Alignment = .bottom {
            didSet {
                layout()
            }
        }
        
        /**
         Hides the divier line.
         */
        public var isHidden: Bool {
            get { line?.isHidden ?? true }
            set { line?.isHidden = newValue }
        }
        
        /**
         Initializer that takes in a UIView.
         - Parameter view: A UIView reference.
         - Parameter thickness: A CGFloat value.
         */
        internal init(view: UIView?, thickness: CGFloat = 1) {
            self.view = view
            self.thickness = thickness
        }
        
        /// Lays out the divider.
        public func layout() {
            guard let l = line, let v = view else {
                return
            }

            let c = contentEdgeInsets

            switch alignment {
                case .top:
                    l.frame = CGRect(x: c.left, y: c.top, width: v.bounds.width - c.left - c.right, height: thickness)
                    l.autoresizingMask = [.flexibleWidth]
                case .bottom:
                    l.frame = CGRect(x: c.left, y: v.bounds.height - thickness - c.bottom, width: v.bounds.width - c.left - c.right, height: thickness)
                    l.autoresizingMask = [.flexibleWidth]
                case .left:
                    l.frame = CGRect(x: c.left, y: c.top, width: thickness, height: v.bounds.height - c.top - c.bottom)
                    l.autoresizingMask = [.flexibleHeight]
                case .right:
                    l.frame = CGRect(x: v.bounds.width - thickness - c.right, y: c.top, width: thickness, height: v.bounds.height - c.top - c.bottom)
                    l.autoresizingMask = [.flexibleHeight]
            }
        }
    }
}

extension Utils.UI.Separator {
    @objc(Alignment)
    public enum Alignment: Int {
      case top
      case left
      case bottom
      case right
    }
}
