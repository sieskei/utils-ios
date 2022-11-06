//
//  Bar.swift
//  
//
//  Created by Miroslav Yozov on 5.11.22.
//

import UIKit

extension Utils.UI.Bar {
    @objc(Alignment)
    public enum Alignment: Int {
      case full
      case center
    }
}

extension Utils.UI {
    open class Bar: Utils.UI.View {
        /// Will layout the view.
        open var allowLayout: Bool {
            bounds.width > 0 && bounds.height > 0 && superview != nil && !grid.isDeferred
        }
        
        /// Should center the contentView.
        open var contentViewAlignment = Alignment.full {
            didSet {
                layoutSubviews()
            }
        }
        
        /// A wrapper around grid.contentEdgeInsets.
        open var contentEdgeInsets: UIEdgeInsets {
            get {
                grid.contentEdgeInsets
            }
            set(value) {
                grid.contentEdgeInsets = value
            }
        }
        
        /// A wrapper around grid.interimSpace.
        open var interimSpace: CGFloat {
            get {
                grid.interimSpace
            }
            set(value) {
                grid.interimSpace = value
            }
        }
        
        /// Grid cell factor.
        open var gridFactor: CGFloat = 12 {
            didSet {
                assert(0 < gridFactor, "[Utils.UI Error: gridFactor must be greater than 0.]")
                layoutSubviews()
            }
        }
        
        /// ContentView that holds the any desired subviews.
        public let contentView = UIView()
        
        /// Left side UIViews.
        open var leftViews = [UIView]() {
            didSet {
                oldValue.forEach {
                    $0.removeFromSuperview()
                }
                layoutSubviews()
            }
        }
        
        /// Right side UIViews.
        open var rightViews = [UIView]() {
            didSet {
                oldValue.forEach {
                    $0.removeFromSuperview()
                }
                layoutSubviews()
            }
        }
        
        /// Center UIViews.
        open var centerViews: [UIView] {
            get {
                return contentView.grid.views
            }
            set(value) {
                contentView.grid.views = value
            }
        }
        
        /**
         An initializer that initializes the object with a NSCoder object.
         - Parameter aDecoder: A NSCoder instance.
         */
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        /**
         An initializer that initializes the object with a CGRect object.
         If AutoLayout is used, it is better to initilize the instance
         using the init() initializer.
         - Parameter frame: A CGRect instance.
         */
        public override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        /**
         A convenience initializer with parameter settings.
         - Parameter leftViews: An Array of UIViews that go on the left side.
         - Parameter rightViews: An Array of UIViews that go on the right side.
         - Parameter centerViews: An Array of UIViews that go in the center.
         */
        public convenience init(leftViews: [UIView]? = nil, rightViews: [UIView]? = nil, centerViews: [UIView]? = nil) {
            self.init()
            self.leftViews = leftViews ?? []
            self.rightViews = rightViews ?? []
            self.centerViews = centerViews ?? []
        }
        
        open override func layoutSubviews() {
            super.layoutSubviews()
            
            guard allowLayout else {
                return
            }
            
            var lc = 0
            var rc = 0
            
            grid.begin()
            grid.views.removeAll()
            
            for v in leftViews {
                if let b = v as? UIButton {
                    b.contentEdgeInsets = .zero
                    b.titleEdgeInsets = .zero
                }

                v.frame.size.width = v.intrinsicContentSize.width
                v.sizeToFit()
                v.grid.columns = Int(ceil(v.bounds.width / gridFactor)) + 2

                lc += v.grid.columns

                grid.views.append(v)
            }
            
            grid.views.append(contentView)
            
            for v in rightViews {
                if let b = v as? UIButton {
                    b.contentEdgeInsets = .zero
                    b.titleEdgeInsets = .zero
                }

                v.frame.size.width = v.intrinsicContentSize.width
                v.sizeToFit()
                v.grid.columns = Int(ceil(v.bounds.width / gridFactor)) + 2

                rc += v.grid.columns

                grid.views.append(v)
            }
            
            contentView.grid.begin()
            contentView.grid.offset.columns = 0
            
            var l: CGFloat = 0
            var r: CGFloat = 0
            
            if .center == contentViewAlignment {
                if leftViews.count < rightViews.count {
                    r = CGFloat(rightViews.count) * interimSpace
                    l = r
                } else {
                    l = CGFloat(leftViews.count) * interimSpace
                    r = l
                }
            }
            
            let p = bounds.width - l - r - contentEdgeInsets.left - contentEdgeInsets.right
            let columns = Int(ceil(p / gridFactor))
            
            if .center == contentViewAlignment {
                if lc < rc {
                    contentView.grid.columns = columns - 2 * rc
                    contentView.grid.offset.columns = rc - lc
                } else {
                    contentView.grid.columns = columns - 2 * lc
                    rightViews.first?.grid.offset.columns = lc - rc
                }
            } else {
                contentView.grid.columns = columns - lc - rc
            }
            
            grid.axis.columns = columns
            grid.commit()
            contentView.grid.commit()
            
            layoutSeparator()
        }
        
        open override func prepare() {
            super.prepare()
            
            autoresizingMask = .flexibleWidth
            
            // frame.size.height = Utils.UI.HeightPreset.normal.value // or set(heightPreset: .normal)
            
            interimSpace = Utils.UI.SpacePreset.space1.value
            contentEdgeInsets = EdgeInsetsPreset.square1.value

            prepareContentView()
        }
    }
}

extension Utils.UI.Bar {
    /// Prepares the contentView.
    fileprivate func prepareContentView() {
        contentView.contentScaleFactor = Utils.UI.Screen.scale
    }
}

