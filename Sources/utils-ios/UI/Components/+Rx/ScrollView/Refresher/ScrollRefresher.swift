//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 19.07.22.0x0246
//

import UIKit
import RxSwift

// MARK: - Scroll refresher API
public protocol UtilsUIScrollRefresher {
    typealias Action = (_ refresher: UtilsUIScrollRefresher, _ trigger: AnyObject, _ token: String) -> Void
    
    func start(by object: AnyObject) -> String
    func start(by object: AnyObject, delay: DispatchTimeInterval) -> String
    func stop(by object: AnyObject, token: String)
}


public extension UtilsUIScrollRefresher {
    func start(by object: AnyObject) -> String {
        start(by: object, delay: .seconds(0))
    }
}


// MARK: - Enable refresher.
extension UIScrollView {
    public static var refresherColors: (base: UIColor, arrow: UIColor) {
        get {
            (Utils.UI.ScrollRefresher.View.Constants.color, Utils.UI.ScrollRefresher.View.Constants.arrowColor)
        }
        set {
            Utils.UI.ScrollRefresher.View.Constants.color = newValue.base
            Utils.UI.ScrollRefresher.View.Constants.arrowColor = newValue.arrow
        }
    }
    
    private var refresherView: Utils.UI.ScrollRefresher.View? {
        subviews.first { $0 is Utils.UI.ScrollRefresher.View } as? Utils.UI.ScrollRefresher.View
    }
    
    public var refresher: UtilsUIScrollRefresher? {
        refresherView
    }
    
    public func refresher(_ action: @escaping UtilsUIScrollRefresher.Action) {
        guard refresherView == nil else {
            return
        }
        
        let view: Utils.UI.ScrollRefresher.View = .init(action: action)
        let height = Utils.UI.ScrollRefresher.View.Constants.height
        let width = bounds.size.width
        view.frame = .init(x: 0, y: -height, width: width, height: height)
        view.autoresizingMask = [view.autoresizingMask, .flexibleWidth]
        view.alpha = 0.0
        
        addSubview(view)
    }
}



