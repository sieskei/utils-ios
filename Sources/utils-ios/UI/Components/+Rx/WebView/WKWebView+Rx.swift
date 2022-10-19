//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 19.10.22.
//

import WebKit
import RxSwift

extension Reactive where Base: WKWebView {
    public func evaluateJavaScript<T>(_ javaScriptString: String) -> Single<T> {
        .create(subscribe: { observer in
            base.evaluateJavaScript(javaScriptString) {
                let r: Result<T, Error> = Utils.resultOf(value: $0, error: $1)
                switch r {
                case .success(let r):
                    observer(.success(r))
                case .failure(let error):
                    observer(.failure(error))
                }
            }
            return Disposables.create { }
        })
    }
}
