//
//  FastLayer.swift
//
//  Created by Miroslav Yozov on 14.05.18.
//  Copyright © 2018 Net Info.BG EAD. All rights reserved.
//

import UIKit

class FastLayer: CALayer {
    let circle: FastCircleLayer
    var arrow: FastArrowLayer
    
    let color: UIColor
    let arrowColor: UIColor
    let lineWidth: CGFloat
    
    init(frame: CGRect, color: UIColor = .init(rgb: (214, 214, 214)), arrowColor: UIColor = .init(rgb: (165, 165, 165)), lineWidth: CGFloat = 1) {
        self.color      = color
        self.arrowColor = arrowColor
        self.lineWidth  = lineWidth
        self.circle = .init(frame: .init(origin: .zero, size: frame.size), color: color, pointColor: arrowColor, lineWidth: lineWidth)
        self.arrow = .init(frame: .init(origin: .zero, size: frame.size), color: arrowColor, lineWidth: lineWidth)
        
        super.init()
        
        self.frame = frame
        self.backgroundColor = UIColor.clear.cgColor
        
        addSublayer(circle)
        addSublayer(arrow)
    }
    
    override init(layer: Any) {
        self.color = .init(rgb: (214, 214, 214))
        self.arrowColor = .init(rgb: (165, 165, 165))
        self.lineWidth  = 1
        self.circle = .init(frame: .zero, color: color, pointColor: arrowColor, lineWidth: lineWidth)
        self.arrow = .init(frame: .zero, color: arrowColor, lineWidth: lineWidth)
        
        super.init(layer: layer)
        
        addSublayer(circle)
        addSublayer(arrow)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
