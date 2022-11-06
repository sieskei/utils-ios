//
//  Space.swift
//  
//
//  Created by Miroslav Yozov on 25.07.22.
//

import UIKit

extension Utils.UI {
    @objc(SpacePreset)
    public enum SpacePreset: Int {
        case none
        case space1
        case space2
        case space3
        case space4
        case space5
        case space6
        case space7
        case space8
        case space9
        case space10
        case space11
        case space12
        case space13
        case space14
        case space15
        case space16
        case space17
        case space18
        
        var value: CGFloat {
            switch self {
            case .none:
                return 0
            case .space1:
                return 1
            case .space2:
                return 2
            case .space3:
                return 4
            case .space4:
                return 8
            case .space5:
                return 12
            case .space6:
                return 16
            case .space7:
                return 20
            case .space8:
                return 24
            case .space9:
                return 28
            case .space10:
                return 32
            case .space11:
                return 36
            case .space12:
                return 40
            case .space13:
                return 44
            case .space14:
                return 48
            case .space15:
                return 52
            case .space16:
                return 56
            case .space17:
                return 60
            case .space18:
                return 64
            }
        }
    }
}
