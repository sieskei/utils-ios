//
//  UIView+Gradient.swift
//  
//
//  Created by Miroslav Yozov on 26.11.19.
//

import UIKit

public typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint)

public enum GradientOrientation {
    case topRightBottomLeft
    case topLeftBottomRight
    case horizontal
    case vertical
    
    var startPoint : CGPoint {
        return points.startPoint
    }
    
    var endPoint : CGPoint {
        return points.endPoint
    }
    
    var points : GradientPoints {
        get {
            switch(self) {
            case .topRightBottomLeft:
                return (.init(x: 0.0, y: 1.0), .init(x: 1.0, y: 0.0))
            case .topLeftBottomRight:
                return (.init(x: 0.0, y: 0.0), .init(x: 1, y: 1))
            case .horizontal:
                return (.init(x: 0.0, y: 0.5), .init(x: 1.0, y: 0.5))
            case .vertical:
                return (.init(x: 0.0, y: 0.0), .init(x: 0.0, y: 1.0))
            }
        }
    }
}

public enum GradientLocation {
    case fullScreen
    case quaterScreen
    case onethirdScreen
    case halfScreen
    case twothirdScreen
    case custom(coordinates: [NSNumber])
    
    var coordinates: [NSNumber] {
        switch self {
        case .fullScreen:
            return [0.0, 1.0]
        case .quaterScreen:
            return [0.0, 0.25]
        case .onethirdScreen:
            return [0.0, 0.33]
        case .halfScreen:
            return [0.0, 0.5]
        case .twothirdScreen:
            return [0.0, 0.66]
        case .custom(let coordinates):
            return coordinates
        }
    }
}

public class GradientView: UIView {
    public override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    public override var layer: CAGradientLayer {
        return super.layer as! CAGradientLayer
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public init(frame: CGRect, colours: [UIColor], orientation: GradientOrientation, location: GradientLocation) {
        super.init(frame: frame)
        applyGradient(withColours: colours, orientation: orientation, location: location)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func applyGradient(withColours colours: [UIColor], orientation: GradientOrientation, location: GradientLocation) -> Void {
        layer.colors = colours.map { $0.cgColor }
        layer.startPoint = orientation.startPoint
        layer.endPoint = orientation.endPoint
        layer.locations = location.coordinates
    }
}
