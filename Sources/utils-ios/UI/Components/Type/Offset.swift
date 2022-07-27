//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 27.07.22.
//

import UIKit

extension Utils.UI {
    public typealias Offset = UIOffset
}

extension CGSize {
    /// Returns an Offset version of the CGSize.
    public var asOffset: Utils.UI.Offset {
        .init(size: self)
    }
}

extension Utils.UI.Offset {
  /**
   Initializer that accepts a CGSize value.
   - Parameter size: A CGSize value.
   */
  public init(size: CGSize) {
    self.init(horizontal: size.width, vertical: size.height)
  }
}

extension Utils.UI.Offset {
  /// Returns a CGSize version of the Offset.
  public var asSize: CGSize {
    return CGSize(width: horizontal, height: vertical)
  }
}
