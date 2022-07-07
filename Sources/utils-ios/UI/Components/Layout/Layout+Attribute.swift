//
//  Layout+Attribute.swift
//  
//
//  Created by Miroslav Yozov on 6.07.22.
//

import UIKit

extension Utils.UI.Layout {
    /// A typealias for NSLayoutConstraint.Attribute
    public typealias Attribute = NSLayoutConstraint.Attribute
}

internal extension Array where Element == Utils.UI.Layout.Attribute {
  /// A LayoutAttribute array containing top and left.
  static var topLeft: [Element] {
    return [.top, .left]
  }
  
  /// A LayoutAttribute array containing top and right.
  static var topRight: [Element] {
    return [.top, .right]
  }
  
  /// A LayoutAttribute array containing bottom and left.
  static var bottomLeft: [Element] {
    return [.bottom, .left]
  }
  
  /// A LayoutAttribute array containing bottom and right.
  static var bottomRight: [Element] {
    return [.bottom, .right]
  }
  
  /// A LayoutAttribute array containing left and right.
  static var leftRight: [Element] {
    return [.left, .right]
  }
  
  /// A LayoutAttribute array containing top and leading.
  static var topLeading: [Element] {
    return [.top, .leading]
  }
  
  /// A LayoutAttribute array containing top and trailing.
  static var topTrailing: [Element] {
    return [.top, .trailing]
  }
  
  /// A LayoutAttribute array containing bottom and leading.
  static var bottomLeading: [Element] {
    return [.bottom, .leading]
  }
  
  /// A LayoutAttribute array containing bottom and trailing.
  static var bottomTrailing: [Element] {
    return [.bottom, .trailing]
  }
  
  /// A LayoutAttribute array containing left and trailing.
  static var leadingTrailing: [Element] {
    return [.leading, .trailing]
  }
  
  /// A LayoutAttribute array containing top and bottom.
  static var topBottom: [Element] {
    return [.top, .bottom]
  }
  
  /// A LayoutAttribute array containing centerX and centerY.
  static var center: [Element] {
    return [.centerX, .centerY]
  }
  
  /// A LayoutAttribute array containing top, left, bottom and right.
  static var edges: [Element] {
    return [.top, .left, .bottom, .right]
  }
  
  /// A LayoutAttribute array for constant height.
  static var constantHeight: [Element] {
    return [.height, .notAnAttribute]
  }
  
  /// A LayoutAttribute array for constant width.
  static var constantWidth: [Element] {
    return [.width, .notAnAttribute]
  }
}
