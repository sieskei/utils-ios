//
//  Screen.swift
//  
//
//  Created by Miroslav Yozov on 5.04.22.
//

import UIKit

extension Utils.UI {
    public struct Screen {
      /// Retrieves the device bounds.
      public static var bounds: CGRect {
        return UIScreen.main.bounds
      }
      
      /// Retrieves the device width.
      public static var width: CGFloat {
        return bounds.width
      }
      
      /// Retrieves the device height.
      public static var height: CGFloat {
        return bounds.height
      }
      
      /// Retrieves the device scale.
      public static var scale: CGFloat {
        return UIScreen.main.scale
      }
    }
}
