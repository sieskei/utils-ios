//
//  SliderView.swift
//  vesti-ios
//
//  Created by Miroslav Yozov on 15.07.20.
//  Copyright © 2020 Netinfo. All rights reserved.
//

import UIKit

import RxSwift
import RxGesture

open class SliderView: UIView {
    open var makeEementInstance: UIView {
        fatalError("Has not been implemented yet!")
    }
    
    public private (set) var selected: Int = 0
    
    open var count: Int {
        fatalError("Has not been implemented yet!")
    }
    
    public let disposeBag = DisposeBag()
    
    private lazy var holderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let l = makeEementInstance
        let c = makeEementInstance
        let r = makeEementInstance
        
        [l, c, r].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            l.topAnchor.constraint(equalTo: view.topAnchor),
            l.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            c.topAnchor.constraint(equalTo: view.topAnchor),
            c.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            r.topAnchor.constraint(equalTo: view.topAnchor),
            r.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            c.widthAnchor.constraint(equalTo: l.widthAnchor),
            r.widthAnchor.constraint(equalTo: l.widthAnchor)
        ])
        
        arrange(left: l, center: c, right: r, in: view)
        
        return view
    }()
    
    private var positionConstraint: NSLayoutConstraint? { // center x, left or right
        didSet {
            oldValue?.isActive = false
            positionConstraint?.isActive = true
        }
    }
    
    private var alignmentConstraints: [NSLayoutConstraint] = [] {
        didSet {
            oldValue.forEach {
                $0.isActive = false
            }
            
            NSLayoutConstraint.activate(alignmentConstraints)
        }
    }
    
    public enum Position: Int {
        case left
        case center
        case right
    }
    
    private var leftView: UIView {
        return holderView.subviews[0]
    }
    
    private var centerView: UIView {
        return holderView.subviews[1]
    }
    
    private var rightView: UIView {
        return holderView.subviews[2]
    }
    
    private subscript(positions: Position...) -> [UIView] {
        var s = [UIView]()
        positions.forEach {
            s.append(holderView.subviews[$0.rawValue])
        }
        return s
    }
    
    public init(selected i : Int = 0, count c: Int = 0) {
        super.init(frame: .zero)
        selected = min(max(0, i), c - 1)
        prepare()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    open func prepare() {
        backgroundColor = .clear
        
        prepareLayout()
        prepareGestures()
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if nil != newWindow {
            prepare(view: leftView, at: .left)
            prepare(view: centerView, at: .center)
            prepare(view: rightView, at: .right)
            
            didAppear(view: centerView)
        }
    }
    
    open func prepare(view: UIView, at position: Position) { }
    
    open func didAppear(view: UIView) { }
    open func didDisappear(view: UIView) { }
}

public extension SliderView {
    enum Direction {
        case left
        case right
        case up
        case down
    }
    
    func close(_ direction: Direction) {
        switch direction {
            
        case .left:
            positionConstraint?.constant = -frame.width
        case .right:
            positionConstraint?.constant = frame.width
        case .up, .down:
            fatalError("Not supported yet!")
        }
        
        setNeedsLayout()
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: { [t = self] in
            t[.left, .center, .right].forEach {
                $0.alpha = 0
                $0.transform = .init(scaleX: 0.9, y: 0.9)
            }
            t.alpha = 0
            t.layoutIfNeeded()
        }, completion: { [t = self] _ in
            t.removeFromSuperview()
        })
    }
    
    enum Step {
        case next
        case prev
        
        func can(_ selected: Int, count: Int) -> Bool {
            switch self {
            case .next:
                return selected + 1 <= count - 1
            case .prev:
                return selected - 1 >= 0
            }
        }
    }
    
    fileprivate func select(_ step: Step, isGesture flag: Bool) {
        guard step.can(selected, count: count) else {
            return
        }
        
        if !flag {
            // nothing to do for now
        }
        
        let tbh: [UIView] // to be hide
            let tbs: [UIView] // to be show
            let s: Int // selected
            
            switch step {
            case .next:
                s = selected + 1
                tbh = self[.left, .center]
                tbs = self[.right]
                
                positionConstraint = holderView.rightAnchor.constraint(equalTo: rightAnchor)
            case .prev:
                s = selected - 1
                tbh = self[.right, .center]
                tbs = self[.left]
                
                positionConstraint = holderView.leftAnchor.constraint(equalTo: leftAnchor)
            }
            
            setNeedsLayout()
            UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 3, options: .curveEaseInOut, animations: { [t = self] in
                tbh.forEach {
                    $0.alpha = 0
                    $0.transform = .init(scaleX: 0.9, y: 0.9)
                }
                
                tbs.forEach {
                    $0.alpha = 1
                    $0.transform = .identity
                }
                
                t.layoutIfNeeded()
            }, completion: { [t = self] _ in
                t.set(selected: s)
            })
    }
    
    func select(_ step: Step) {
        select(step, isGesture: false)
    }
}

fileprivate extension SliderView {
    func recenter() {
        positionConstraint = holderView.centerXAnchor.constraint(equalTo: centerXAnchor)
        
        self[.left, .right].forEach {
            $0.alpha = 0
            $0.transform = .init(scaleX: 0.9, y: 0.9)
        }
        
        self[.center].forEach {
            $0.alpha = 1
            $0.transform = .identity
        }
    }
    
    func arrange(left l: UIView, center c: UIView, right r: UIView, in view: UIView) {
        view.insertSubview(l, at: 0)
        view.insertSubview(c, at: 1)
        view.insertSubview(r, at: 2)
        
        alignmentConstraints = [
            l.leftAnchor.constraint(equalTo: view.leftAnchor),
            c.leftAnchor.constraint(equalTo: l.rightAnchor),
            r.leftAnchor.constraint(equalTo: c.rightAnchor),
            r.rightAnchor.constraint(equalTo: view.rightAnchor)
        ]
    }
    
    func set(selected i: Int) {
        guard selected != i else {
            return
        }
        
        let cc = centerView
        defer {
            didDisappear(view: cc)
            didAppear(view: centerView)
        }
        
        let s = selected
        selected = i
        
        let l = leftView
        let c = centerView
        let r = rightView
        
        if i > s { // switched to right
            prepare(view: c, at: .left)
            prepare(view: l, at: .right)
            
            arrange(left: c, center: r, right: l, in: holderView)
        } else { // switched to left
            prepare(view: r, at: .left)
            prepare(view: c, at: .right)
            
            arrange(left: r, center: l, right: c, in: holderView)
        }
        
        recenter()
    }
    
    func prepareLayout() {
        addSubview(holderView)
        NSLayoutConstraint.activate([holderView.topAnchor.constraint(equalTo: topAnchor),
                                     holderView.bottomAnchor.constraint(equalTo: bottomAnchor),
                                     holderView.subviews[0].widthAnchor.constraint(equalTo: widthAnchor)])
        recenter()
        
        // for debug
        leftView.backgroundColor = .red
        centerView.backgroundColor = .green
        rightView.backgroundColor = .blue
    }
    
    func prepareGestures() {
        let pan = rx.panGesture {
            $1.beginPolicy = .custom({ [weak self] gesture in
                guard let this = self, let pan = gesture as? UIPanGestureRecognizer else {
                    return false
                }
                
                let v = pan.velocity(in: this)
                return abs(v.x) > abs(v.y)
            })
        }
        
        pan
            .when(.began)
            .subscribeNext(weak: self) { this, _ in
                
            }.disposed(by: disposeBag)
        
        pan
            .when(.changed)
            .asTranslation()
            .subscribeNext(weak: self) {
                let p = abs($1.translation.x / $0.frame.width)
                let p_3 = p / 3
                
                if $0.selected == 0 { // first
                    if $1.translation.x > 0 {
                        $0.positionConstraint?.constant = $1.translation.x / 5
                        $0[.center, .right].forEach {
                            $0.alpha = 1 - p_3
                            $0.transform = .init(scaleX: 1 - (0.1 * p_3), y: 1 - (0.1 * p_3))
                        }
                        return
                    }
                    
                } else if $0.selected == $0.count - 1 { // last
                    if $1.translation.x < 0 {
                        $0.positionConstraint?.constant = $1.translation.x / 5
                        $0[.left, .center].forEach {
                            $0.alpha = 1 - p_3
                            $0.transform = .init(scaleX: 1 - (0.1 * p_3), y: 1 - (0.1 * p_3))
                        }
                        return
                    }
                }
                
                $0.positionConstraint?.constant = $1.translation.x
                $0[.left, .right].forEach {
                    $0.alpha = p
                    $0.transform = .init(scaleX: 0.9 + (0.1 * p), y: 0.9 + (0.1 * p))
                }
                
                $0[.center].forEach {
                    $0.alpha = 1 - p
                    $0.transform = .init(scaleX: 1 - (0.1 * p), y: 1 - (0.1 * p))
                }
            }
            .disposed(by: disposeBag)
        
        
        pan
        .when(.cancelled, .failed, .ended)
        .asTranslation()
        .subscribeNext(weak: self) {
            let p = abs(($1.translation.x + $1.velocity.x) / $0.frame.width)
            
            let revert = { [t = $0] in
                t.positionConstraint?.constant = 0
                t.setNeedsLayout()
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 3, options: .curveEaseInOut, animations: {
                    t[.left, .right].forEach {
                        $0.alpha = 0
                        $0.transform = .init(scaleX: 0.9, y: 0.9)
                    }
                    
                    t[.center].forEach {
                        $0.alpha = 1
                        $0.transform = .identity
                    }
                    
                    t.layoutIfNeeded()
                })
            }
            
            if $0.selected == 0 { // first
                if $1.translation.x > 0 {
                    if p > 0.5 {
                        $0.close(.right)
                    } else {
                        revert()
                    }
                    return
                }
            } else if $0.selected == $0.count - 1 { // last
                if $1.translation.x < 0 {
                    if p > 0.5 {
                        $0.close(.left)
                    } else {
                        revert()
                    }
                    return
                }
            }
            
            if $1.translation.x < 0 {
                if p > 0.5 {
                    $0.select(.next, isGesture: true)
                } else {
                    revert()
                }
            } else {
                if p > 0.5 {
                    $0.select(.prev, isGesture: true)
                } else {
                    revert()
                }
            }
        }
        .disposed(by: disposeBag)
    }
}
