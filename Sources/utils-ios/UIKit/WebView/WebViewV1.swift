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

open class WebViewV1: WKWebView {
    public enum NavigationState: Equatable {
        case not
        case ongoing(WKNavigation)
        case done
        case fail
        
        var isOngoing: Bool {
            switch self {
            case .ongoing:
                return true
            default:
                return false
            }
        }
    }
    
    private let disposeBag = DisposeBag()
    
    public let loadingState: EquatableValue<NavigationState> = .init(.not)
    public let headerBoundsPauser: EquatableValue<Bool> = .init(true)
    
    public private (set) lazy var headerContainerView: UIView = {
        let view = UIView()
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
        
        prepareHeaderContainerView()
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let sY = max(0, scrollView.contentOffset.y)
        let hY = max(0, -convert(CGPoint.zero, from: headerContainerView).y)
        let hSize = headerContainerView.frame.size
        let hPoint = convert(point, to: headerContainerView)
        
        let visibleRect: CGRect = .init(origin: .init(x: 0, y: hY), size: .init(width: hSize.width, height: hSize.height - (hY + (sY - hY))))
        if visibleRect.contains(hPoint) {
            return headerContainerView.hitTest(hPoint, with: event) ?? super.hitTest(point, with: event)
        } else {
            return super.hitTest(point, with: event)
        }
    }
    
    private func set(marginTop margin: CGFloat) {
        evaluateJavaScript("document.body.style.marginTop = \"\(margin)px\"")
    }
}

fileprivate extension WebViewV1 {
    func prepareHeaderContainerView() {
        let view = headerContainerView
        
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.insertSubview(view, at: 0)
        
        // static constraints
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor)
        ])

        // dynamic top constraint
        let topConstraint = view.topAnchor.constraint(equalTo: topAnchor)
        topConstraint.isActive = true
        
        var topConstraintConstantBegan: CGFloat?
        scrollView.rx.contentOffset
            .map(unowned: scrollView) {
                let bounceOffsetRaw = $0.bounceBottomOffsetRaw
                guard bounceOffsetRaw >= 0 && $0.contentFillsVerticalScrollEdges else {
                    topConstraintConstantBegan = nil
                    return -max(0, ($1.y / 4).rounded())
                }
                
                if topConstraintConstantBegan == nil {
                    topConstraintConstantBegan = -topConstraint.constant
                }
                
                return -max(0, topConstraintConstantBegan! + bounceOffsetRaw)
            }
            .distinctUntilChanged()
            .bind(to: topConstraint.rx.constant)
            .disposed(by: disposeBag)
        
        // bounds observe + pause until load and custom pauser
        view.rx.observeWeakly(CGRect.self, #keyPath(UIView.bounds))
            .pausableBuffered(loadingState.map { !$0.isOngoing })
            .pausable(headerBoundsPauser)
            .map { $0?.height ?? 0 }
            .distinctUntilChanged()
            .subscribeNext(weak: self) { this, height in
                this.set(marginTop: height)
        }.disposed(by: disposeBag)
    }
}


// ---------------------
// MARK: Reactive tools.
// ---------------------
public extension Reactive where Base: WebViewV1 {
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
