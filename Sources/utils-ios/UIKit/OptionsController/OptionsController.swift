//
//  OptionsController.swift
//  
//
//  Created by Miroslav Yozov on 31.10.20.
//

import UIKit
import Material

import RxSwift
import RxSwiftExt

public class OptionsController: ViewController {
    public class TitleLabel:    utils_ios.Label { }
    public class MesssageLabel: utils_ios.Label { }
    
    public class ContentView:  Material.View { }
    public class FreeAreaView: Material.View { }
    
    private let disposeBag = DisposeBag()
    
    private lazy var titleLabel: TitleLabel = {
        let l: TitleLabel = .init()
        l.numberOfLines = 0
        l.setContentHuggingPriority(.required, for: .vertical)
        l.setContentCompressionResistancePriority(.required, for: .vertical)
        return l
    }()
    
    private lazy var messageLabel: MesssageLabel = {
        let l: MesssageLabel = .init()
        l.numberOfLines = 0
        l.setContentHuggingPriority(.required, for: .vertical)
        l.setContentCompressionResistancePriority(.required, for: .vertical)
        return l
    }()
    
    public private (set) lazy var contentView: ContentView = {
        let v: ContentView = .init()
        return v
    }()
    
    public private (set) lazy var freeAreaView: FreeAreaView = {
        let v: FreeAreaView = .init()
        v.backgroundColor = .black
        v.alpha = 0.5
        
        v.rx
            .tapGesture()
            .subscribeNext(weak: self) { this, _ in
                this.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        return v
    }()
    
    fileprivate lazy var tableView: TableView = {
        let view: TableView = .init()
        
        Observable.of(actions)
            .bind(to: view.rx.items) { tableView, row, item in
                let cell: TableViewCell = tableView.dequeueReusableCell(for: row)
                cell.model = .value(item)
                return cell
            }.disposed(by: disposeBag)
        
        return view
    }()
    
    public override var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    public var message: String? {
        get { messageLabel.text }
        set { messageLabel.text = newValue }
    }
    
    public var actions: [Action] = []
    
    public override var modalTransitionStyle: UIModalTransitionStyle {
        get { .crossDissolve }
        set { }
    }
    
    public override var modalPresentationStyle: UIModalPresentationStyle {
        get { .overFullScreen }
        set { }
    }
    
    public override func prepare() {
        super.prepare()
        
        view.backgroundColor = .clear
        
        view.layout(freeAreaView)
            .top()
            .left()
            .right()
        
        view.layout(contentView)
            .left()
            .right()
            .top(freeAreaView.anchor.bottom)
            .bottom()
        
        contentView.layout(tableView)
            .leftSafe(16)
            .rightSafe(16)
            .bottomSafe(16)
        
        contentView.layout(messageLabel)
            .leftSafe(16)
            .rightSafe(16)
            .bottom(tableView.anchor.top, 8)
        
        contentView.layout(titleLabel)
            .leftSafe(16)
            .rightSafe(16)
            .top(16)
            .bottom(messageLabel.anchor.top, 8)
    }
}

extension OptionsController {
    public class Action: Equatable {
        public static func == (lhs: OptionsController.Action, rhs: OptionsController.Action) -> Bool {
            lhs.ID == rhs.ID
        }
        
        public enum Style {
            case normal
            case destructive
        }
        
        public let name: String
        public let style: Style
        
        public private (set) var ID: Int = {
            Int.randomIdentifier
        }()
        
        public init(name n: String, style s: Style = .normal) {
            name = n
            style = s
        }
    }
}

public extension Reactive where Base: OptionsController {
    var action: Observable<Base.Action> {
        base.tableView.rx
            .itemSelected
            .map(weak: base.tableView, default: nil) { view, indexPath in
                guard let cell = view.cellForRow(at: indexPath) as? Base.TableViewCell else {
                    return nil
                }
                
                switch cell.model {
                case .empty:
                    return nil
                case .value(let action):
                    return action
                }
            }
            .unwrap()
    }
}
