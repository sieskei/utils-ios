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
        let view = UIView(frame: .init(origin: .zero, size: .init(width: bounds.width, height: 0)))
        view.backgroundColor = .clear
        return view
    }()
    
    public private (set) lazy var footerContainerView: UIView = {
        let view = UIView(frame: .init(origin: .zero, size: .init(width: bounds.width, height: 0)))
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
        prepareFooterContainerView()
        prepareBodyInsets()
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return headerContainerView.hitTest(convert(point, to: headerContainerView), with: event) ?? super.hitTest(point, with: event)
    }
}

fileprivate extension WebView {
    enum Margin: Equatable {
        case top(CGFloat)
        case bottom(CGFloat)
        
        var script: String {
            switch self {
            case .top(let v):
                return "document.body.style.marginTop = \"\(v)px\""
            case .bottom(let v):
                return "document.body.style.marginBottom = \"\(v)px\""
            }
        }
    }
    
    private func set(bodyMargin margin: Margin) {
        evaluateJavaScript(margin.script)
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
    }
    
    func prepareFooterContainerView() {
        let view = footerContainerView
        
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.insertSubview(view, at: 1)
        
        let vh = view.rx.observeWeakly(CGRect.self, #keyPath(UIView.bounds)).map { $0?.height ?? 0 }
        let cs = scrollView.rx.observeWeakly(CGSize.self, #keyPath(UIScrollView.contentSize)).map { $0?.height ?? 0 }
        let co = scrollView.rx.observeWeakly(CGPoint.self, #keyPath(UIScrollView.contentOffset)).map { $0?.y ?? 0 }
        
        // dynamic top constraint
        let topConstraint = view.topAnchor.constraint(equalTo: topAnchor)
        Observable.combineLatest(vh, cs, co).map { ($1 - $0) - $2 }.distinctUntilChanged().bind(to: topConstraint.rx.constant).disposed(by: disposeBag)

        // static constraints
        NSLayoutConstraint.activate([
            topConstraint,
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func prepareBodyInsets() {
        typealias O = Observable<Margin>
        
        let hv = headerContainerView
        let fv = footerContainerView
        
        let l = rx.observeWeakly(Bool.self, #keyPath(WKWebView.isLoading), options: [.new]).map { $0 ?? false }.filter { !$0 }
        
        /*
         Top inset (margin) based on header view height.
        */
        let lh: O = l.pausableBuffered(headerBoundsPauser, limit: nil).mapWeakly(weak: hv, default: .top(0)) { v, _ in .top(v.bounds.height) }
        let hh: O = hv.rx.observeWeakly(CGRect.self, #keyPath(UIView.bounds)).pausable(headerBoundsPauser).map { .top($0?.height ?? 0) }
        
        /*
         Bottom inset (margin) based on footer view height.
        */
        let lf: O = l.mapWeakly(weak: fv, default: .bottom(0)) { v, _ in .bottom(v.bounds.height) }
        let hf: O = fv.rx.observeWeakly(CGRect.self, #keyPath(UIView.bounds)).map { .bottom($0?.height ?? 0) }
        
        Observable.merge(lh, hh, lf, hf).distinctUntilChanged().subscribeNextWeakly(weak: self) {
            $0.set(bodyMargin: $1)
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
