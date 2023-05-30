//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 30.05.23.
//

import UIKit

public protocol UtilsUILabelLinkableDelegate: AnyObject {
    func label(_ label: Utils.UI.Label.Linkable, didPressLink: URL)
}

extension Utils.UI.Label {
    open class Linkable: Utils.UI.Label {
        private var links: [Link] = []
        
        private var activeLink: Link? = nil {
            didSet {
                if let link = activeLink {
                    guard let text = attributedText else {
                        return
                    }
                    
                    let src: NSMutableAttributedString = .init(attributedString: text)
                    src.setAttributes([.foregroundColor: hoverColor], range: link.result.range)
                    attributedText = src
                } else {
                    guard let link = oldValue else {
                        return
                    }
                    
                    Utils.UI.async(delay: 0.125, with: self) {
                        guard let text = $0.attributedText else {
                            return
                        }
                        
                        let src: NSMutableAttributedString = .init(attributedString: text)
                        if let color = link.foregroundColor {
                            src.setAttributes([.foregroundColor: color], range: link.result.range)
                        } else {
                            src.removeAttribute(.foregroundColor, range: link.result.range)
                        }
                        
                        $0.attributedText = src
                    }
                }
            }
        }
        
        private lazy var tapGesture: UITapGestureRecognizer = .init(target: self, action: #selector(onTap)) ~> {
            $0.delegate = self
            
            $0.delaysTouchesBegan = false
            $0.delaysTouchesEnded = false
        }
        
        public var hoverColor: UIColor = .blue
        public weak var delegate: UtilsUILabelLinkableDelegate? = nil
        
        open override func prepare() {
            super.prepare()
            isUserInteractionEnabled = true
            addGestureRecognizer(tapGesture)
        }
    }
}

// MARK: HTML
extension Utils.UI.Label.Linkable {
    override func set(HTML source: NSAttributedString?) {
        links.removeAll()
        
        guard let source = source else {
            return
        }
        
        let src: NSMutableAttributedString = .init(attributedString: source)
        source.enumerateAttributes(in: source.range) { attributes, range, _ in
            if let link = attributes[.link], let url = link as? URL {
                src.removeAttribute(.link, range: range)
                
                let link: Link = .init(attributes[.foregroundColor] as? UIColor, .linkCheckingResult(range: range, url: url))
                links.append(link)
            }
        }
        
        attributedText = src
    }
}

// MARK: Touches
extension Utils.UI.Label.Linkable {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self), let link = link(at: point) {
            activeLink = link
        }
        super.touchesBegan(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeLink = nil
        super.touchesEnded(touches, with: event)
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeLink = nil
        super.touchesEnded(touches, with: event)
    }
}

extension Utils.UI.Label.Linkable: UIGestureRecognizerDelegate {
    @objc
    fileprivate func onTap(sender: UITapGestureRecognizer) {
        guard let link = link(at: sender.location(in: self)) else {
            return
        }
        
        if let delegate, let url = link.result.url {
            delegate.label(self, didPressLink: url)
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: self)
        let index = indexOfAttributedTextCharacterAtPoint(point)
        return links.contains { NSLocationInRange(index, $0.result.range) }
    }
}

// MARK: Helpers
fileprivate extension Utils.UI.Label.Linkable {
    struct Link {
        let foregroundColor: UIColor?
        let result: NSTextCheckingResult
        
        init(_ c: UIColor?, _ r: NSTextCheckingResult) {
            foregroundColor = c
            result = r
        }
    }
    
    func link(at point: CGPoint) -> Link? {
        let index = indexOfAttributedTextCharacterAtPoint(point)
        guard index != -1, let link = links.first(where: { NSLocationInRange(index, $0.result.range) == true }) else {
            return nil
        }
        
        return link
    }
    
    func indexOfAttributedTextCharacterAtPoint(_ point: CGPoint) -> Int {
        guard let aString = self.attributedText else {
            return -1
        }
        
        let textStorage: NSTextStorage = .init(attributedString: aString)
        let layoutManager: NSLayoutManager = .init()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer: NSTextContainer = .init(size: frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
}
