//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 25.10.20.
//

import UIKit

@objc(UtilsUITextFieldDelegate)
public protocol UtilsUITextFieldDelegate: UITextFieldDelegate {
    /**
     A delegation method that is executed when the textField changed.
     - Parameter textField: A TextField.
     - Parameter didChange text: An optional String.
    */
    @objc
    optional func textField(textField: Utils.UI.TextField, didChange text: String?)

    /**
     A delegation method that is executed when the textField will clear.
     - Parameter textField: A TextField.
     - Parameter willClear text: An optional String.
    */
    @objc
    optional func textField(textField: Utils.UI.TextField, willClear text: String?)

    /**
     A delegation method that is executed when the textField is cleared.
     - Parameter textField: A TextField.
     - Parameter didClear text: An optional String.
    */
    @objc
    optional func textField(textField: Utils.UI.TextField, didClear text: String?)
}

extension Utils.UI.TextField {
    @objc(PlaceholderAnimation)
    public enum PlaceholderAnimation: Int {
        case `default`
        case hidden
    }
}

extension Utils.UI {
    open class TextField: UITextField {
        /// Minimum TextField text height.
        private let minimumTextHeight: CGFloat = 32
        
        /// EdgeInsets for text.
        @objc
        open var textInsets: UIEdgeInsets = .zero
        
        /// A boolean indicating whether the text is empty.
        open var isEmpty: Bool {
            text?.utf16.count == .zero
        }
        
        
        // ========= //
        // Left view //
        // ========= //
        
        open override var leftView: UIView? {
            didSet {
                prepareLeftView()
                layoutSubviews() // ???
            }
        }
        
        /// The leftView width value.
        open var leftViewWidth: CGFloat {
            guard nil != leftView else {
                return 0
            }
            return leftViewOffset + bounds.height
        }
        
        /// The leftView offset value.
        open var leftViewOffset: CGFloat = 16
        
        /// Placeholder normal text
        open var leftViewNormalColor = Utils.UI.Color.darkText.others {
            didSet {
                updateLeftViewColor()
            }
        }
        
        /// Placeholder active text
        open var leftViewActiveColor: UIColor = .blue {
            didSet {
                updateLeftViewColor()
            }
        }
        
        
        // =========== //
        // Placeholder //
        // =========== //
        
        /// The placeholder UILabel.
        public let placeholderLabel: UILabel = .init()
        
        /// The placeholderLabel text value.
        @IBInspectable
        open override var placeholder: String? {
            get {
                placeholderLabel.text
            }
            set(value) {
                if isEditing && isPlaceholderUppercasedWhenEditing {
                    placeholderLabel.text = value?.uppercased()
                } else {
                    placeholderLabel.text = value
                }
                layoutSubviews() // ???
            }
        }
        
        @IBInspectable
        open var isPlaceholderUppercasedWhenEditing = false {
            didSet {
                updatePlaceholderTextToActiveState()
            }
        }
        
        /// A Boolean that indicates if the placeholder label is animated.
        open var isPlaceholderAnimated = true
        
        /// Set the placeholder animation value.
        open var placeholderAnimation: PlaceholderAnimation = .default {
            didSet {
                updatePlaceholderVisibility()
            }
        }
        
        /// Placeholder normal text
        open var placeholderNormalColor = Utils.UI.Color.darkText.others {
            didSet {
                updatePlaceholderLabelColor()
            }
        }
        
        /// Placeholder active text
        open var placeholderActiveColor: UIColor = .blue {
            didSet {
                /// Keep tintColor update here. See #1229
                tintColor = placeholderActiveColor
                updatePlaceholderLabelColor()
            }
        }
        
        /// This property adds a padding to placeholder y position animation
        open var placeholderVerticalOffset: CGFloat = 0
        
        /// This property adds a padding to placeholder y position animation
        open var placeholderHorizontalOffset: CGFloat = 0
        
        /// The scale of the active placeholder in relation to the inactive
        open var placeholderActiveScale: CGFloat = 0.75 {
            didSet {
                layoutPlaceholderLabel()
            }
        }
        
        
        // ======= //
        // Details //
        // ======= //
        
        /// The detailLabel UILabel that is displayed.
        public let detailLabel: UILabel = .init()
        
        /// The detailLabel text value.
        open var detail: String? {
            get {
                return detailLabel.text
            }
            set(value) {
                detailLabel.text = value
                layoutSubviews() // ???
            }
        }
        
        /// Detail text
        open var detailColor = Color.darkText.others {
            didSet {
                updateDetailLabelColor()
            }
        }
        
        /// Vertical distance for the detailLabel from the divider.
        open var detailVerticalOffset: CGFloat = 8 {
            didSet {
                layoutSubviews() // ???
            }
        }
        
        
        // ========= //
        // Separator //
        // ========= //
        
        /// Separator normal height.
        open var separatorNormalHeight: CGFloat = 1 {
            didSet {
                updateSeparatorHeight()
            }
        }
        
        /// Separator active height.
        open var separatorActiveHeight: CGFloat = 2 {
            didSet {
                updateSeparatorHeight()
            }
        }
        
        /// Separator normal color.
        open var separatorNormalColor: UIColor = .gray {
            didSet {
                updateSeparatorColor()
            }
        }
        
        /// Separator active color.
        open var separatorActiveColor: UIColor = .blue {
            didSet {
                updateSeparatorColor()
            }
        }
        
        // ============ //
        // Clear button //
        // ============ //
        /// A reference to the clearIconButton.
        open fileprivate(set) var clearIconButton: Utils.UI.Button?
        
        /// Enables the clearIconButton.
        open var isClearIconButtonEnabled: Bool {
            get {
                clearIconButton != nil
            }
            set {
                guard newValue else {
                    clearIconButton?.removeTarget(self, action: #selector(handleClearIconButton), for: .touchUpInside)
                    removeFromRightView(view: clearIconButton)
                    clearIconButton = nil
                    return
                }

                guard nil == clearIconButton else {
                    return
                }

                clearIconButton = Utils.UI.Button.icon(Utils.UI.Icon.clear, tintColor: placeholderNormalColor)
                clearIconButton!.contentEdgeInsetsPreset = .none
                clearIconButton!.pulseType = .none
                
                rightView?.grid.views.insert(clearIconButton!, at: 0)
                isClearIconButtonAutoHandled = { isClearIconButtonAutoHandled }()

                layoutSubviews() // ???
            }
        }
        
        /// Enables the automatic handling of the clearIconButton.
        open var isClearIconButtonAutoHandled = true {
            didSet {
                clearIconButton?.removeTarget(self, action: #selector(handleClearIconButton), for: .touchUpInside)

                guard isClearIconButtonAutoHandled else {
                    return
                }

                clearIconButton?.addTarget(self, action: #selector(handleClearIconButton), for: .touchUpInside)
            }
        }

        
        // ================= //
        // Visibility button //
        // ================= //
        
        /// A reference to the visibilityIconButton.
        open fileprivate(set) var visibilityIconButton: Utils.UI.Button?
        
        /// Icon for visibilityIconButton when in the on state.
        open var visibilityIconOn = Utils.UI.Icon.visibility {
            didSet {
                updateVisibilityIcon()
            }
        }
        
        /// Icon for visibilityIconButton when in the off state.
        open var visibilityIconOff = Utils.UI.Icon.visibilityOff {
            didSet {
                updateVisibilityIcon()
            }
        }
        
        /// Enables the visibilityIconButton.
        @IBInspectable
        open var isVisibilityIconButtonEnabled: Bool {
            get {
                visibilityIconButton != nil
            }
            set {
                guard newValue else {
                    visibilityIconButton?.removeTarget(self, action: #selector(handleVisibilityIconButton), for: .touchUpInside)
                    removeFromRightView(view: visibilityIconButton)
                    visibilityIconButton = nil
                    return
                }

                guard nil == visibilityIconButton else {
                    return
                }

                isSecureTextEntry = true
                visibilityIconButton = Utils.UI.Button.icon(nil, tintColor: placeholderNormalColor.withAlphaComponent(0.54))
                updateVisibilityIcon()
                visibilityIconButton!.contentEdgeInsetsPreset = .none
                visibilityIconButton?.pulseType = .center

                rightView?.grid.views.append(visibilityIconButton!)
                isVisibilityIconButtonAutoHandled = { isVisibilityIconButtonAutoHandled }()

                layoutSubviews() // ???
            }
        }
        
        /// Enables the automatic handling of the visibilityIconButton.
        @IBInspectable
        open var isVisibilityIconButtonAutoHandled = true {
            didSet {
                visibilityIconButton?.removeTarget(self, action: #selector(handleVisibilityIconButton), for: .touchUpInside)
                guard isVisibilityIconButtonAutoHandled else {
                    return
                }
                visibilityIconButton?.addTarget(self, action: #selector(handleVisibilityIconButton), for: .touchUpInside)
            }
        }
        
        open override var text: String? {
            didSet {
                updatePlaceholderVisibility()
            }
        }
        
        /// Handles the textAlignment of the placeholderLabel.
        open override var textAlignment: NSTextAlignment {
            didSet {
                placeholderLabel.textAlignment = textAlignment
                detailLabel.textAlignment = textAlignment
            }
        }
        
        /// Handles the font of the placeholderLabel.
        open override var font: UIFont? {
            didSet {
                placeholderLabel.font = font
            }
        }
        
        open override var isSecureTextEntry: Bool {
            didSet {
                updateVisibilityIcon()
                fixCursorPosition()
            }
        }
        
        /// Default size when using AutoLayout.
        open override var intrinsicContentSize: CGSize {
            let height = textInsets.top + textInsets.bottom + minimumTextHeight
            return .init(width: bounds.width, height: max(height, super.intrinsicContentSize.height))
        }
        
        /**
         An initializer that initializes the object with a NSCoder object.
         - Parameter aDecoder: A NSCoder instance.
         */
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            prepare()
        }
        
        /**
         An initializer that initializes the object with a CGRect object.
         If AutoLayout is used, it is better to initilize the instance
         using the init() initializer.
         - Parameter frame: A CGRect instance.
         */
        public override init(frame: CGRect) {
            super.init(frame: frame)
            prepare()

            /// Fire didSet here to update tintColor
            placeholderActiveColor = { placeholderActiveColor }()
        }
        
        open override func layoutSubviews() {
            super.layoutSubviews()
            
            // layoutShape()
            
            layoutPlaceholderLabel()
            layoutBottomLabel(label: detailLabel, verticalOffset: detailVerticalOffset)
            layoutSeparator()
            layoutLeftView()
            layoutRightView()
        }
        
        open override func textRect(forBounds bounds: CGRect) -> CGRect {
            super.textRect(forBounds: bounds).inset(by: textInsets)
        }
        
        open override func editingRect(forBounds bounds: CGRect) -> CGRect {
            textRect(forBounds: bounds)
        }
        
        /**
         Prepares the view instance when intialized. When subclassing,
         it is recommended to override the prepare method
         to initialize property values and other setup operations.
         The super.prepare method should always be called immediately
         when subclassing.
         */
        open func prepare() {
            clipsToBounds = false
            borderStyle = .none
            contentScaleFactor = Utils.UI.Screen.scale
            
            backgroundColor = nil
            font = Utils.UI.Font.systemFont()
            textColor = Utils.UI.Color.darkText.primary
            
            prepareSeparator()
            preparePlaceholderLabel()
            prepareDetailLabel()
            prepareTargetHandlers()
            prepareTextAlignment()
            prepareRightView()
        }
    }
}

fileprivate extension Utils.UI.TextField {
    /// Prepares the divider.
    func prepareSeparator() {
        separatorColor = separatorNormalColor
    }

    /// Prepares the placeholderLabel.
    func preparePlaceholderLabel() {
        placeholderNormalColor = Utils.UI.Color.darkText.others
        placeholderLabel.backgroundColor = .clear
        addSubview(placeholderLabel)
    }

    /// Prepares the detailLabel.
    func prepareDetailLabel() {
        detailLabel.font = Utils.UI.Font.systemFont(ofSize: 12)
        detailLabel.numberOfLines = 0
        detailColor = Utils.UI.Color.darkText.others
        addSubview(detailLabel)
    }

    /// Prepares the leftView.
    func prepareLeftView() {
        leftView?.contentMode = .left
        leftViewMode = .always
        updateLeftViewColor()
    }

    /// Prepares the target handlers.
    func prepareTargetHandlers() {
        addTarget(self, action: #selector(handleEditingDidBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(handleEditingChanged), for: .editingChanged)
        addTarget(self, action: #selector(handleEditingDidEnd), for: .editingDidEnd)
    }

    /// Prepares the textAlignment.
    func prepareTextAlignment() {
        textAlignment = .rightToLeft == UIApplication.shared.userInterfaceLayoutDirection ? .right : .left
    }

    /// Prepares the rightView.
    func prepareRightView() {
        rightView = UIView()
        rightView?.grid.columns = 2
        rightViewMode = .whileEditing
        clearButtonMode = .never
    }
}

fileprivate extension Utils.UI.TextField {
    /// Updates the leftView tint color.
    func updateLeftViewColor() {
        leftView?.tintColor = isEditing ? leftViewActiveColor : leftViewNormalColor
    }

    /// Updates the placeholderLabel text color.
    func updatePlaceholderLabelColor() {
        placeholderLabel.textColor = isEditing ? placeholderActiveColor : placeholderNormalColor
    }

    /// Updates the placeholder visibility.
    func updatePlaceholderVisibility() {
        guard isEditing else {
            placeholderLabel.isHidden = !isEmpty && .hidden == placeholderAnimation
            return
        }

        placeholderLabel.isHidden = .hidden == placeholderAnimation
    }

    /// Updates the dividerColor.
    func updateSeparatorColor() {
        separatorColor = isEditing ? separatorActiveColor : separatorNormalColor
    }

    /// Updates the dividerThickness.
    func updateSeparatorHeight() {
        separatorThickness = isEditing ? separatorActiveHeight : separatorNormalHeight
    }

    /// Update the placeholder text to the active state.
    func updatePlaceholderTextToActiveState() {
        guard isPlaceholderUppercasedWhenEditing else {
            return
        }

        guard isEditing || !isEmpty else {
            return
        }

        placeholderLabel.text = placeholderLabel.text?.uppercased()
    }

    /// Update the placeholder text to the normal state.
    func updatePlaceholderTextToNormalState() {
        guard isPlaceholderUppercasedWhenEditing else {
            return
        }

        guard isEmpty else {
            return
        }

        placeholderLabel.text = placeholderLabel.text?.capitalized
    }

    /// Updates the detailLabel text color.
    func updateDetailLabelColor() {
        detailLabel.textColor = detailColor
    }
}

fileprivate extension Utils.UI.TextField {
    /// Layout the placeholderLabel.
    func layoutPlaceholderLabel() {
        let leftPadding = leftViewWidth + textInsets.left
        let w = bounds.width - leftPadding - textInsets.right
        var h = placeholderLabel.sizeThatFits(CGSize(width: w, height: .greatestFiniteMagnitude)).height
        h = min(h, bounds.height - textInsets.top - textInsets.bottom)
        h = max(h, minimumTextHeight)

        placeholderLabel.bounds.size = CGSize(width: w, height: h)

        guard isEditing || !isEmpty || !isPlaceholderAnimated else {
            placeholderLabel.transform = CGAffineTransform.identity
            placeholderLabel.frame.origin = CGPoint(x: leftPadding, y: textInsets.top)
            return
        }

        placeholderLabel.transform = CGAffineTransform(scaleX: placeholderActiveScale, y: placeholderActiveScale)
        placeholderLabel.frame.origin.y = -placeholderLabel.frame.height + placeholderVerticalOffset

        switch placeholderLabel.textAlignment {
        case .left, .natural:
            placeholderLabel.frame.origin.x = leftPadding + placeholderHorizontalOffset
        case .right:
        let scaledWidth = w * placeholderActiveScale
            placeholderLabel.frame.origin.x = bounds.width - scaledWidth - textInsets.right + placeholderHorizontalOffset
        default:
            break
        }
    }

    /// Layout the leftView.
    func layoutLeftView() {
        guard let v = leftView else {
            return
        }

        let w = leftViewWidth
        v.frame = CGRect(x: 0, y: 0, width: w, height: bounds.height)
        separatorContentEdgeInsets.left = w
    }
    
    /// Layout the rightView.
    func layoutRightView() {
        guard let v = rightView else {
            return
        }

        let w = CGFloat(v.grid.views.count) * bounds.height
        v.frame = CGRect(x: bounds.width - w, y: 0, width: w, height: bounds.height)
        v.grid.layout()
    }
}

internal extension Utils.UI.TextField {
  /// Layout given label at the bottom with the vertical offset provided.
  func layoutBottomLabel(label: UILabel, verticalOffset: CGFloat) {
    let c = separatorContentEdgeInsets
    label.frame.origin.x = c.left
    label.frame.origin.y = bounds.height + verticalOffset
    label.frame.size.width = bounds.width - c.left - c.right
    label.frame.size.height = label.sizeThatFits(CGSize(width: label.bounds.width, height: .greatestFiniteMagnitude)).height
  }
}

fileprivate extension Utils.UI.TextField {
    /// Handles the text editing did begin state.
    @objc
    func handleEditingDidBegin() {
        leftViewEditingBeginAnimation()
        placeholderEditingDidBeginAnimation()
        dividerEditingDidBeginAnimation()
    }

    // Live updates the textField text.
    @objc
    func handleEditingChanged(textField: UITextField) {
        (delegate as? UtilsUITextFieldDelegate)?.textField?(textField: self, didChange: textField.text)
    }

    /// Handles the text editing did end state.
    @objc
    func handleEditingDidEnd() {
        leftViewEditingEndAnimation()
        placeholderEditingDidEndAnimation()
        dividerEditingDidEndAnimation()
    }

    /// Handles the clearIconButton TouchUpInside event.
    @objc
    func handleClearIconButton() {
        guard nil == delegate?.textFieldShouldClear || true == delegate?.textFieldShouldClear?(self) else {
            return
        }

        let t = text

        (delegate as? UtilsUITextFieldDelegate)?.textField?(textField: self, willClear: t)

        text = nil

        (delegate as? UtilsUITextFieldDelegate)?.textField?(textField: self, didClear: t)
    }

        /// Handles the visibilityIconButton TouchUpInside event.
    @objc
    func handleVisibilityIconButton() {
        UIView.transition(
            with: (visibilityIconButton?.imageView)!,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.isSecureTextEntry = !self.isSecureTextEntry
            })
    }
}

private extension Utils.UI.TextField {
    /// The animation for leftView when editing begins.
    func leftViewEditingBeginAnimation() {
        updateLeftViewColor()
    }

    /// The animation for leftView when editing ends.
    func leftViewEditingEndAnimation() {
        updateLeftViewColor()
    }

    /// The animation for the divider when editing begins.
    func dividerEditingDidBeginAnimation() {
        updateSeparatorHeight()
        updateSeparatorColor()
    }

    /// The animation for the divider when editing ends.
    func dividerEditingDidEndAnimation() {
        updateSeparatorHeight()
        updateSeparatorColor()
    }

    /// The animation for the placeholder when editing begins.
    func placeholderEditingDidBeginAnimation() {
        updatePlaceholderVisibility()
        updatePlaceholderLabelColor()

        guard isPlaceholderAnimated else {
            return
        }

        updatePlaceholderTextToActiveState()
        UIView.animate(withDuration: 0.15, animations: layoutPlaceholderLabel)
    }

    /// The animation for the placeholder when editing ends.
    func placeholderEditingDidEndAnimation() {
        updatePlaceholderVisibility()
        updatePlaceholderLabelColor()

        guard isPlaceholderAnimated else {
            return
        }

        updatePlaceholderTextToNormalState()
        UIView.animate(withDuration: 0.15, animations: layoutPlaceholderLabel)
    }
}

private extension Utils.UI.TextField {
    /// Updates visibilityIconButton image based on isSecureTextEntry value.
    func updateVisibilityIcon() {
        visibilityIconButton?.image = isSecureTextEntry ? visibilityIconOff : visibilityIconOn
    }

    /// Remove view from rightView.
    func removeFromRightView(view: UIView?) {
        guard let v = view, let i = rightView?.grid.views.firstIndex(of: v) else {
            return
        }

        rightView?.grid.views.remove(at: i)
    }

    /**
    Reassign text to reset cursor position.
    Fixes issue-1119. Previously issue-1030, and issue-1023.
    */
    func fixCursorPosition() {
        let t = text
        text = nil
        text = t
    }
}
