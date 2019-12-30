//
//  WebView.swift
//  
//
//  Created by Miroslav Yozov on 24.12.19.
//

import UIKit
import WebKit

import RxSwift
import RxSwiftExt
import RxCocoa

open class WebView: WKWebView {
    public enum NavigationState: Equatable {
        case not
        case ongoing(WKNavigation)
        case done
        case fail
    }
    
    private let disposeBag = DisposeBag()
    
    public let loadingState: EquatableValue<NavigationState> = .init(.not)
    public let headerBoundsPauser: EquatableValue<Bool> = .init(true)
    
    public private (set) lazy var headerContainerView: UIView = {
        let view = PassthroughView()
        view.backgroundColor = .clear
        return view
    }()
    
    public convenience init(configuration: WKWebViewConfiguration = WKWebViewConfiguration()) {
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        self.init(frame: .zero, configuration: configuration)
    }
    
    public convenience init(frame: CGRect) {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        self.init(frame: frame, configuration: configuration)
    }
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        prepare()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepare()
    }
    
    open func prepare() {
        isOpaque = false
        backgroundColor = .clear
        scrollView.backgroundColor = .clear
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        layoutHeader()
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return headerContainerView.hitTest(convert(point, to: headerContainerView), with: event) ?? super.hitTest(point, with: event)
    }
    
    private func layoutHeader() {
        guard let superview = superview else  {
            return
        }
        
        let view = headerContainerView
        
        if view.superview != superview {
            view.removeFromSuperview()
            
            view.translatesAutoresizingMaskIntoConstraints = false
            superview.insertSubview(view, belowSubview: self)
        }
        
        // leading & trailing
        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        // top + move over until bottom bounce
        let top = view.topAnchor.constraint(equalTo: topAnchor)
        top.isActive = true
        
        var topBegin: CGFloat?
        scrollView.rx.contentOffset
            .map(unowned: scrollView) {
                let bounceOffsetRaw = $0.bounceBottomOffsetRaw
                guard bounceOffsetRaw >= 0 && $0.contentFillsVerticalScrollEdges else {
                    topBegin = nil
                    return -max(0, $1.y / 4)
                }
                
                if topBegin == nil {
                    topBegin = -top.constant
                }
                
                return -max(0, topBegin! + bounceOffsetRaw)
            }
            .distinctUntilChanged()
            .bind(to: top.rx.constant)
            .disposed(by: disposeBag)
        
        // maximum height
        view.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor).isActive = true
        
        // bounds observe + pause until load and custom pauser
        view.rx.observeWeakly(CGRect.self, #keyPath(UIView.bounds))
            .pausableBuffered(loadingState.map {
                switch $0 {
                case .ongoing:
                    return false
                default:
                    return true
                }
            })
            .pausable(headerBoundsPauser)
            .map { $0?.height ?? 0 }
            .distinctUntilChanged()
            .subscribeNextWeakly(weak: self) { this, height in
                this.set(marginTop: height)
        }.disposed(by: disposeBag)
    }
    
    private func set(marginTop margin: CGFloat) {
        evaluateJavaScript("document.body.style.marginTop = \"\(margin)px\"")
        scrollView.scrollIndicatorInsets.top = margin
    }
}


// ---------------------
// MARK: Reactive tools.
// ---------------------
public extension Reactive where Base: WebView {
    var isHeaderBoundsPaused: Binder<Bool> {
        return Binder(self.base) { view, pause in
            view.headerBoundsPauser.value = !pause
        }
    }
    
    var loadingState: Binder<Base.NavigationState> {
        return Binder(self.base) { view, state in
            view.loadingState.value = state
        }
    }
}
