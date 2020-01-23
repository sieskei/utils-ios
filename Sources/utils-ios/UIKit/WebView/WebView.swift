//
//  WebView.swift
//  
//
//  Created by Miroslav Yozov on 15.01.20.
//

import UIKit
import WebKit

import RxSwift
import RxSwiftExt
import RxCocoa

open class WebView: WKWebView {
    private let disposeBag = DisposeBag()
    
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
        return headerContainerView.hitTest(convert(point, to: headerContainerView), with: event) ?? super.hitTest(point, with: event)
    }
}

fileprivate extension WebView {
    private func set(bodyMarginTop margin: CGFloat) {
        evaluateJavaScript("document.body.style.marginTop = \"\(margin)px\"")
    }
    
    func prepareHeaderContainerView() {
        let view = headerContainerView
        
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.insertSubview(view, at: 0)
        
        // dynamic top constraint
        let topConstraint = view.topAnchor.constraint(equalTo: topAnchor)
        scrollView.rx.contentOffset.map { -max(0, $0.y ) }.bind(to: topConstraint.rx.constant).disposed(by: disposeBag)
        
        // static constraints
        NSLayoutConstraint.activate([
            topConstraint,
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        // allways set margin when loading finished
        let loadingSource = rx.observeWeakly(Bool.self, #keyPath(WKWebView.isLoading)).map { $0 ?? false }
        loadingSource.filter { !$0 }.subscribeNextWeakly(weak: self) { this, flag in
            this.set(bodyMarginTop: view.bounds.height)
        }.disposed(by: disposeBag)
        
        // bounds observe + pause until loading and custom pauser
        view.rx.observeWeakly(CGRect.self, #keyPath(UIView.bounds))
            // .pausableBuffered(loadingSource.map { !$0 }, limit: nil)
            .pausable(headerBoundsPauser)
            .map { $0?.height ?? 0 }
            .distinctUntilChanged()
            .subscribeNextWeakly(weak: self) { this, height in
                this.set(bodyMarginTop: height)
        }.disposed(by: disposeBag)
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
}
