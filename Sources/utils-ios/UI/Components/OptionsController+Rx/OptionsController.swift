//
//  OptionsController.swift
//  
//
//  Created by Miroslav Yozov on 31.10.20.
//

import UIKit
import RxSwift
import RxSwiftExt

public class OptionsController: Utils.UI.ViewController {
    public class TitleLabel:    Utils.UI.Label { }
    public class MesssageLabel: Utils.UI.Label { }
    
    public class ContentView:  Utils.UI.View { }
    public class FreeAreaView: Utils.UI.View { }
    public class TableViewWrapper: Utils.UI.View { }
    
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
        v.backgroundColor = .clear
        v.rx
            .tapGesture()
            .subscribeNext(with: self) { this, _ in
                this.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        return v
    }()
    
    public private (set) lazy var tableView: TableView = {
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
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        modalPresentationStyle = .custom
        transitioningDelegate = self
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
        
        let c: TableViewWrapper = .init()
        c.layout(tableView).edges()
        contentView.layout(c)
            .leftSafe(16)
            .rightSafe(16)
            .bottomSafe(16)
        
        contentView.layout(messageLabel)
            .leftSafe(16)
            .rightSafe(16)
            .bottom(c.anchor.top, 8)
        
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
        
        public init(ID: Int = .randomIdentifier, name n: String, style s: Style = .normal) {
            self.ID = ID
            self.name = n
            self.style = s
        }
    }
}

public extension Reactive where Base: OptionsController {
    var action: Observable<Base.Action> {
        base.tableView.rx
            .itemSelected
            .map(with: base.tableView, default: nil) { view, indexPath in
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

extension OptionsController: UIViewControllerTransitioningDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return presented == self ? DimmingPresentationController(presentedViewController: presented, presenting: presenting) : nil
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presented == self ? SlidePresentationAnimationController(isPresenting: true, duration: 0.35) : nil
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissed == self ? SlidePresentationAnimationController(isPresenting: false, duration: 0.5) : nil
    }
}
