//
//  UIColor+.swift
//  
//
//  Created by Miroslav Yozov on 26.11.19.
//

import UIKit

public extension UIColor {
    static var random: UIColor {
        return UIColor(red:   CGFloat(arc4random()) / CGFloat(UInt32.max),
                       green: CGFloat(arc4random()) / CGFloat(UInt32.max),
                       blue:  CGFloat(arc4random()) / CGFloat(UInt32.max),
                       alpha: 1.0)
    }
    
    convenience init(rgb: (CGFloat, CGFloat, CGFloat), alpha: CGFloat = 1.00) {
        self.init(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: alpha)
    }
    
    /**
     A convenience initializer that creates color from
     argb(alpha red green blue) hexadecimal representation.
     - Parameter argb: An unsigned 32 bit integer. E.g 0xFFAA44CC.
     */
    convenience init(argb: UInt32) {
        let a = argb >> 24
        let r = argb >> 16
        let g = argb >> 8
        let b = argb >> 0

        func f(_ v: UInt32) -> CGFloat {
            return CGFloat(v & 0xff) / 255
        }

        self.init(red: f(r), green: f(g), blue: f(b), alpha: f(a))
    }
    
    
    /**
     A convenience initializer that creates color from
     rgb(red green blue) hexadecimal representation with alpha value 1.
     - Parameter rgb: An unsigned 32 bit integer. E.g 0xAA44CC.
     */
    convenience init(rgb: UInt32) {
        self.init(argb: (0xff000000 as UInt32) | rgb)
    }
    
    /**
     Define UIColor from hex value
     
     - Parameter rgbValue - hex color value
     - Parameter alpha - transparency level
     */
    convenience init(hex: UInt32, alpha: CGFloat = 1.00) {
        let red   = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0x00FF00) >> 8)  / 255.0
        let blue  = CGFloat((hex & 0x0000FF) >> 0)  / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     Define UIColor from hex string
     
     - Parameter rgbValue - hex color string
     - Parameter alpha - transparency level
     */
    convenience init(hex: String, alpha: CGFloat = 1.00) {
        var colorString: String = hex.trimmingCharacters(in: CharacterSet.whitespaces).uppercased()
        
        if colorString.hasPrefix("#") {
            colorString.remove(at: colorString.startIndex)
        }
        
        guard colorString.count == 6 else {
            self.init(hex: 0x000000, alpha: alpha)
            return
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: colorString).scanHexInt32(&rgbValue)
        
        self.init(hex: rgbValue, alpha: alpha)
    }
    
    /**
     Get hex string from UIColor
     
     - Parameter format - hex format enum
     */
    enum HexFormat {
        case RGB
        case ARGB
        case RGBA
        case RRGGBB
        case AARRGGBB
        case RRGGBBAA
    }
    
    enum HexDigits {
        case d3, d4, d6, d8
    }
    
    func hexString(_ format: HexFormat = .RRGGBBAA) -> String {
        let maxi = [.RGB, .ARGB, .RGBA].contains(format) ? 16 : 256
        
        func toI(_ f: CGFloat) -> Int {
            return min(maxi - 1, Int(CGFloat(maxi) * f))
        }
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let ri = toI(r)
        let gi = toI(g)
        let bi = toI(b)
        let ai = toI(a)
        
        switch format {
            case .RGB:       return String(format: "#%X%X%X", ri, gi, bi)
            case .ARGB:      return String(format: "#%X%X%X%X", ai, ri, gi, bi)
            case .RGBA:      return String(format: "#%X%X%X%X", ri, gi, bi, ai)
            case .RRGGBB:    return String(format: "#%02X%02X%02X", ri, gi, bi)
            case .AARRGGBB:  return String(format: "#%02X%02X%02X%02X", ai, ri, gi, bi)
            case .RRGGBBAA:  return String(format: "#%02X%02X%02X%02X", ri, gi, bi, ai)
        }
    }
    
    func hexString(_ digits: HexDigits) -> String {
        switch digits {
            case .d3: return hexString(.RGB)
            case .d4: return hexString(.RGBA)
            case .d6: return hexString(.RRGGBB)
            case .d8: return hexString(.RRGGBBAA)
        }
    }

}
