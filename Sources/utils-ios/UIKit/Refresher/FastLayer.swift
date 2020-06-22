//
//  FastLayer.swift
//
//  Created by Miroslav Yozov on 14.05.18.
//  Copyright © 2018 Net Info.BG EAD. All rights reserved.
//

import UIKit

class FastLayer: CALayer {
    var circle: FastCircleLayer {
        guard let layers = sublayers, layers.count == 2 else {
            fatalError("Missing sublayers!")
        }
        return Utils.castOrFatalError(layers[0])
    }
    
    var arrow: FastArrowLayer {
        guard let layers = sublayers, layers.count == 2 else {
            fatalError("Missing sublayers!")
        }
        return Utils.castOrFatalError(layers[1])
    }
    
    func prepare(frame: CGRect, color: UIColor = .init(rgb: (214, 214, 214)), arrowColor: UIColor = .init(rgb: (165, 165, 165)), lineWidth: CGFloat = 1) {
        self.frame = frame
        self.backgroundColor = UIColor.clear.cgColor
        
        addSublayer({
            let layer = FastCircleLayer()
            layer.prepare(frame: bounds, color: color, pointColor: arrowColor, lineWidth: lineWidth)
            return layer
        }())
        
        addSublayer({
            let layer = FastArrowLayer()
            layer.prepare(frame: bounds, color: arrowColor, lineWidth: lineWidth)
            return layer
        }())
    }
}
