//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 25.07.22.
//

import UIKit

extension Utils.UI {
    @objc(InterimSpacePreset)
    public enum InterimSpacePreset: Int {
        case none
        case interimSpace1
        case interimSpace2
        case interimSpace3
        case interimSpace4
        case interimSpace5
        case interimSpace6
        case interimSpace7
        case interimSpace8
        case interimSpace9
        case interimSpace10
        case interimSpace11
        case interimSpace12
        case interimSpace13
        case interimSpace14
        case interimSpace15
        case interimSpace16
        case interimSpace17
        case interimSpace18
        
        /// Converts the InterimSpacePreset enum to an InterimSpace value.
        var value: CGFloat {
            switch self {
            case .none:
                return 0
            case .interimSpace1:
                return 1
            case .interimSpace2:
                return 2
            case .interimSpace3:
                return 4
            case .interimSpace4:
                return 8
            case .interimSpace5:
                return 12
            case .interimSpace6:
                return 16
            case .interimSpace7:
                return 20
            case .interimSpace8:
                return 24
            case .interimSpace9:
                return 28
            case .interimSpace10:
                return 32
            case .interimSpace11:
                return 36
            case .interimSpace12:
                return 40
            case .interimSpace13:
                return 44
            case .interimSpace14:
                return 48
            case .interimSpace15:
                return 52
            case .interimSpace16:
                return 56
            case .interimSpace17:
                return 60
            case .interimSpace18:
                return 64
            }
        }
    }
}
