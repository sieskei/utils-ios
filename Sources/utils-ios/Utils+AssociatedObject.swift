//
//  Utils+AssociatedObject.swift
//  
//
//  Created by Miroslav Yozov on 3.02.21.
//

import ObjectiveC

extension Utils {
    public struct AssociatedObject {
        public enum AssociationPolicy: Int {
            case strong
            case weak
            
            fileprivate var objc_value: objc_AssociationPolicy {
                switch self {
                case .strong:
                    return .OBJC_ASSOCIATION_RETAIN
                case .weak:
                    return .OBJC_ASSOCIATION_ASSIGN
                }
            }
        }

        
      /**
       Gets the Obj-C reference for the instance object.
       - Parameter base: Base object.
       - Parameter key: Memory key pointer.
       - Parameter initializer: Object initializer.
       - Returns: The associated reference for the initializer object.
       */
        public static func get<T: Any>(base: Any, key: UnsafePointer<UInt8>, policy: AssociationPolicy = .strong, initializer: () -> T) -> T {
            if let v = objc_getAssociatedObject(base, key) as? T {
                return v
            }
            
            let v = initializer()
            objc_setAssociatedObject(base, key, v, policy.objc_value)
            return v
        }
        
        /**
         Gets the Obj-C reference for the instance object.
         - Parameter base: Base object.
         - Parameter key: Memory key pointer.
         - Parameter initializer: Object initializer.
         - Returns: The associated reference for the initializer object.
         */
          public static func get<T: Any>(base: Any, key: UnsafePointer<UInt8>) -> T? {
              if let v = objc_getAssociatedObject(base, key) as? T {
                  return v
              } else {
                  return nil
              }
          }
        
        
      
      /**
       Sets the Obj-C reference for the instance object.
       - Parameter base: Base object.
       - Parameter key: Memory key pointer.
       - Parameter value: The object instance to set for the associated object.
       - Returns: The associated reference for the initializer object.
       */
        public static func set<T: Any>(base: Any, key: UnsafePointer<UInt8>, policy: AssociationPolicy = .strong, value: T) {
            objc_setAssociatedObject(base, key, value, policy.objc_value)
        }
    }
}
