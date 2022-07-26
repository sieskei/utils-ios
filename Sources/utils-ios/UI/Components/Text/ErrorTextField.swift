//
//  ErrorTextField.swift
//  
//
//  Created by Miroslav Yozov on 26.07.22.
//

import UIKit

extension Utils.UI {
    open class ErrorTextField: Utils.UI.TextField {
        /// The errorLabel UILabel that is displayed.
        public let errorLabel = UILabel()

        /// The errorLabel text value.
        open var error: String? {
            get {
                return errorLabel.text
            }
            set {
                errorLabel.text = newValue
                layoutSubviews()
            }
        }

        /// Error text color.
        open var errorColor: UIColor = .red {
            didSet {
                errorLabel.textColor = errorColor
            }
        }

        /// Vertical distance for the errorLabel from the divider.
        open var errorVerticalOffset: CGFloat = 8 {
            didSet {
                layoutSubviews()
            }
        }

        /// Hide or show error text.
        open var isErrorRevealed: Bool {
            get {
                return !errorLabel.isHidden
            }
            set {
                errorLabel.isHidden = !newValue
                detailLabel.isHidden = newValue
                layoutSubviews()
            }
        }

        open override func prepare() {
            super.prepare()
            isErrorRevealed = false
            prepareErrorLabel()
        }

        /// Prepares the errorLabel.
        func prepareErrorLabel() {
            errorLabel.font = Utils.UI.Font.systemFont(ofSize: 12)
            errorLabel.numberOfLines = 0
            errorColor = { errorColor }() // call didSet
            addSubview(errorLabel)
        }

        open override func layoutSubviews() {
            super.layoutSubviews()
            layoutBottomLabel(label: errorLabel, verticalOffset: errorVerticalOffset)
        }
    }
}
