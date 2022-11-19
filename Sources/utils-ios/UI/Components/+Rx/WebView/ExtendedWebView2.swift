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

extension Utils.UI.ExtendedWebView2 {
    private enum Margin: Equatable {
        case top(CGFloat)
        case bottom(CGFloat)
        
        func script(for scale: CGFloat) -> String {
            switch self {
            case .top(let v):
                return "document.body.style.setProperty(\"margin-top\", \"\(v / scale)px\", \"important\")"
            case .bottom(let v):
                return "document.body.style.setProperty(\"margin-bottom\", \"\(v / scale)px\", \"important\")"
            }
        }
    }
}

extension Utils.UI {
    open class ExtendedWebView2: Utils.UI.WebView {
        private let disposeBag = DisposeBag()
        
        @RxProperty
        public var freezeHeaderBounds: Bool = false
        
        public private (set) lazy var headerContainerView: UIView = {
            headerContainerViewClass.init(frame: .init(origin: .zero, size: .init(width: bounds.width, height: 0)))
        }()
        
        public private (set) lazy var footerContainerView: UIView = {
            footerContainerViewClass.init(frame: .init(origin: .zero, size: .init(width: bounds.width, height: 0)))
        }()
        
        open var headerContainerViewClass: UIView.Type {
            UIView.self
        }
        
        open var footerContainerViewClass: UIView.Type {
            UIView.self
        }
        
        open var headerTopConstraintConstant: Observable<CGFloat> {
            /*
             Follow vertical scroll content offset.
            */
            scrollView.rx.contentOffset.map { -$0.y }
        }
        
        open var footerTopConstraintConstant: Observable<CGFloat> {
            /*
             Follow body size + scale (see top constraint).
            */
            Observable.combineLatest($bodySize.value.map { $0.value.height }, scrollView.rx.zoomScale).map { $0 * $1 }
        }
        
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
            super.init(frame: frame, configuration: configuration, resizeSensor: true)
        }
        
        public required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        open override func prepare() {
            defer {
                super.prepare()
            }
            
            isOpaque = false
            backgroundColor = .clear
            scrollView.backgroundColor = .clear
            
            prepareHeaderContainerView()
            prepareFooterContainerView()
            
            prepareRx()
        }
        
        open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            headerContainerView.hitTest(convert(point, to: headerContainerView), with: event) ??
                footerContainerView.hitTest(convert(point, to: footerContainerView), with: event) ??
                super.hitTest(point, with: event)
        }
        
        deinit {
            Utils.Log.debug(self)
        }
    }
}


fileprivate extension Utils.UI.ExtendedWebView2 {
    func prepareHeaderContainerView() {
        let view = headerContainerView
        
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.insertSubview(view, at: 0)
        
        // dynamic top constraint
        let topConstraint = view.topAnchor.constraint(equalTo: topAnchor)
        headerTopConstraintConstant
            .distinctUntilChanged()
            .bind(to: topConstraint.rx.constant)
            .disposed(by: disposeBag)
        
        // static constraints
        NSLayoutConstraint.activate([
            topConstraint,
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    func prepareFooterContainerView() {
        let view = footerContainerView
        
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.insertSubview(view, at: 1)
        
        // dynamic top constraint
        let topConstraint = view.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor)
        footerTopConstraintConstant
            .distinctUntilChanged()
            .bind(to: topConstraint.rx.constant)
            .disposed(by: disposeBag)
        
        // static constraints
        NSLayoutConstraint.activate([
            topConstraint,
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}


extension Utils.UI.ExtendedWebView2 {
    @objc
    open override dynamic func prepareConfiguration() {
        super.prepareConfiguration()
        
        let ucc = configuration.userContentController
        ucc.addUserScript(.init(source: "document.body.style.display = 'none';", injectionTime: .atDocumentEnd, forMainFrameOnly: true))
    }
    
    @objc
    open dynamic func prepareRx() {
        typealias O = Observable<Margin>
                
        let hv = headerContainerView
        let fv = footerContainerView
        
        /*
         Top inset (margin) based on header view height.
        */
        let hh: O = hv.rx.observeWeakly(CGRect.self, #keyPath(UIView.bounds), options: [.new])
            .pausableBuffered($freezeHeaderBounds.value.map { !$0 }, limit: 1)
            .map { .top($0?.height ?? 0) }
        
        /*
         Bottom inset (margin) based on footer view height.
        */
        let hf: O = fv.rx.observeWeakly(CGRect.self, #keyPath(UIView.bounds), options: [.new])
            .map { .bottom($0?.height ?? 0) }
        
        [hh, hf].forEach {
            // combine with zoom scalee
            Observable.combineLatest(scrollView.rx.zoomScale, $0)
                .pausableBuffered($isReady.value, limit: 1)
                .subscribe(with: self, onNext: {
                    $0.evaluateJavaScript($1.1.script(for: $1.0))
                })
                .disposed(by: disposeBag)
        }
        
        /*
         Display body when document ready.
         */
        $isReady.value
            .filter { $0 }
            .subscribe(with: self, onNext: { this, _ in
                let src =
                """
                    \(Margin.top(this.headerContainerView.bounds.height).script(for: this.scrollView.zoomScale))
                    \(Margin.bottom(this.footerContainerView.bounds.height).script(for: this.scrollView.zoomScale))
                    document.body.style.display = "block";
                """
                this.evaluateJavaScript(src)
            })
            .disposed(by: disposeBag)
    }
}
