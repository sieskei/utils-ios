//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 7.07.22.
//

import Foundation
import UIKit

// MARK: Abstract layout costant type.
public protocol UtilsUILayoutConstantType { }

extension CGFloat: UtilsUILayoutConstantType { }
extension CGSize: UtilsUILayoutConstantType { }
extension UIEdgeInsets: UtilsUILayoutConstantType { }


// MARK: Abstract layout anchor type.
public protocol UtilsUILayoutAnchorType { }

extension NSLayoutAnchor: UtilsUILayoutAnchorType { }
