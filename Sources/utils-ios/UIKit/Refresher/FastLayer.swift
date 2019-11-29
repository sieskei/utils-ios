//
//  FastLayer.swift
//
//  Created by Miroslav Yozov on 14.05.18.
//  Copyright © 2018 Net Info.BG EAD. All rights reserved.
//

import UIKit

class FastLayer: CALayer {
    private (set) lazy var circle: FastCircleLayer = {
        return .init(frame: bounds, color: color, pointColor: arrowColor, lineWidth: lineWidth)
    }()
    
    private (set) lazy var arrow: FastArrowLayer = {
        return .init(frame: bounds, color: arrowColor, lineWidth: lineWidth)
    }()
    
    let color: UIColor
    let arrowColor: UIColor
    let lineWidth: CGFloat
    
    init(frame: CGRect, color: UIColor = .init(rgb: (214, 214, 214)), arrowColor: UIColor = .init(rgb: (165, 165, 165)), lineWidth: CGFloat = 1) {
        self.color      = color
        self.arrowColor = arrowColor
        self.lineWidth  = lineWidth
        super.init()
        self.frame = frame
        backgroundColor = UIColor.clear.cgColor
        
        addSublayer(circle)
        addSublayer(arrow)
    }
    
    override init(layer: Any) {
        guard let fastLayer = layer as? FastLayer else {
            fatalError("Unknown layer! \(layer)")
        }
        self.color = fastLayer.color
        self.arrowColor = fastLayer.arrowColor
        self.lineWidth = fastLayer.lineWidth
        
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
