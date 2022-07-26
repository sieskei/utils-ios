//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 26.07.22.
//

import UIKit

extension Utils.UI {
    @objc(BorderWidthPreset)
    public enum BorderWidthPreset: Int {
      case none
      case border1
      case border2
      case border3
      case border4
      case border5
      case border6
      case border7
      case border8
      case border9
      
      /// A CGFloat representation of the border width preset.
      public var value: CGFloat {
        switch self {
        case .none:
            return 0
        case .border1:
            return 0.5
        case .border2:
            return 1
        case .border3:
            return 2
        case .border4:
            return 3
        case .border5:
            return 4
        case .border6:
            return 5
        case .border7:
            return 6
        case .border8:
            return 7
        case .border9:
            return 8
        }
      }
    }
}


