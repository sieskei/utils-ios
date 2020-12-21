//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 15.12.20.
//

import Foundation

import LoggerAPI
import HeliumLogger

public extension Utils {
    typealias Log = LoggerAPI.Log
}

public extension Utils.Log {
    class func initialize(_ type: LoggerMessageType = .debug) {
        Log.logger = HeliumLogger(type)
    }
    
    private class func message(_ items: Any..., separator: String = " ", terminator: String = "\n") -> String {
        var msg: String = items.reduce(into: "") { $0 += "\(separator)\($1)" }
        msg += terminator
        return msg
    }
    
    /// Log a message for use when in verbose logging mode.
    /// 
    /// - Parameters:
    ///   - items: Zero or more items to be logged.
    ///   - separator: A string to message between each item. The default is a single space (`" "`).
    ///   - terminator: The string to message after all items have been printed. The default is a newline (`"\n"`).
    ///   - lineNum: The line in the source code of the function invoking the logger API. Defaults to the line of the function invoking this function.
    ///   - functionName: The name of the function invoking the logger API. Defaults to the name of the function invoking this function.
    ///   - fileName: The file containing the source code of the function invoking the logger API.
    ///               Defaults to the name of the file containing the function which invokes this function.
    class func verbose(_ items: Any..., separator: String = " ", terminator: String = "\n", functionName: String = #function, lineNum: Int = #line, fileName: String = #file) {
        verbose(message(items, separator, terminator), functionName: functionName, lineNum: lineNum, fileName: fileName)
    }
    
    /// Log an informational message.
    ///
    /// - Parameters:
    ///   - items: Zero or more items to be logged.
    ///   - separator: A string to message between each item. The default is a single space (`" "`).
    ///   - terminator: The string to message after all items have been printed. The default is a newline (`"\n"`).
    ///   - lineNum: The line in the source code of the function invoking the logger API. Defaults to the line of the function invoking this function.
    ///   - functionName: The name of the function invoking the logger API. Defaults to the name of the function invoking this function.
    ///   - fileName: The file containing the source code of the function invoking the logger API.
    ///               Defaults to the name of the file containing the function which invokes this function.
    class func info(_ items: Any..., separator: String = " ", terminator: String = "\n", functionName: String = #function, lineNum: Int = #line, fileName: String = #file) {
        info(message(items, separator, terminator), functionName: functionName, lineNum: lineNum, fileName: fileName)
    }
    
    /// Log a warning message.
    ///
    /// - Parameters:
    ///   - items: Zero or more items to be logged.
    ///   - separator: A string to message between each item. The default is a single space (`" "`).
    ///   - terminator: The string to message after all items have been printed. The default is a newline (`"\n"`).
    ///   - lineNum: The line in the source code of the function invoking the logger API. Defaults to the line of the function invoking this function.
    ///   - functionName: The name of the function invoking the logger API. Defaults to the name of the function invoking this function.
    ///   - fileName: The file containing the source code of the function invoking the logger API.
    ///               Defaults to the name of the file containing the function which invokes this function.
    class func warning(_ items: Any..., separator: String = " ", terminator: String = "\n", functionName: String = #function, lineNum: Int = #line, fileName: String = #file) {
        warning(message(items, separator, terminator), functionName: functionName, lineNum: lineNum, fileName: fileName)
    }
    
    /// Log an error message.
    ///
    /// - Parameters:
    ///   - items: Zero or more items to be logged.
    ///   - separator: A string to message between each item. The default is a single space (`" "`).
    ///   - terminator: The string to message after all items have been printed. The default is a newline (`"\n"`).
    ///   - lineNum: The line in the source code of the function invoking the logger API. Defaults to the line of the function invoking this function.
    ///   - functionName: The name of the function invoking the logger API. Defaults to the name of the function invoking this function.
    ///   - fileName: The file containing the source code of the function invoking the logger API.
    ///               Defaults to the name of the file containing the function which invokes this function.
    class func error(_ items: Any..., separator: String = " ", terminator: String = "\n", functionName: String = #function, lineNum: Int = #line, fileName: String = #file) {
        error(message(items, separator, terminator), functionName: functionName, lineNum: lineNum, fileName: fileName)
    }
    
    /// Log a debugging message.
    ///
    /// - Parameters:
    ///   - items: Zero or more items to be logged.
    ///   - separator: A string to message between each item. The default is a single space (`" "`).
    ///   - terminator: The string to message after all items have been printed. The default is a newline (`"\n"`).
    ///   - lineNum: The line in the source code of the function invoking the logger API. Defaults to the line of the function invoking this function.
    ///   - functionName: The name of the function invoking the logger API. Defaults to the name of the function invoking this function.
    ///   - fileName: The file containing the source code of the function invoking the logger API.
    ///               Defaults to the name of the file containing the function which invokes this function.
    class func debug(_ items: Any..., separator: String = " ", terminator: String = "\n", functionName: String = #function, lineNum: Int = #line, fileName: String = #file) {
        debug(message(items, separator, terminator), functionName: functionName, lineNum: lineNum, fileName: fileName)
    }
    
    /// Log a message when entering a function.
    ///
    /// - Parameters:
    ///   - items: Zero or more items to be logged.
    ///   - separator: A string to message between each item. The default is a single space (`" "`).
    ///   - terminator: The string to message after all items have been printed. The default is a newline (`"\n"`).
    ///   - lineNum: The line in the source code of the function invoking the logger API. Defaults to the line of the function invoking this function.
    ///   - functionName: The name of the function invoking the logger API. Defaults to the name of the function invoking this function.
    ///   - fileName: The file containing the source code of the function invoking the logger API.
    ///               Defaults to the name of the file containing the function which invokes this function.
    class func entry(_ items: Any..., separator: String = " ", terminator: String = "\n", functionName: String = #function, lineNum: Int = #line, fileName: String = #file) {
        entry(message(items, separator, terminator), functionName: functionName, lineNum: lineNum, fileName: fileName)
    }
    
    /// Log a message when exiting a function.
    ///
    /// - Parameters:
    ///   - items: Zero or more items to be logged.
    ///   - separator: A string to message between each item. The default is a single space (`" "`).
    ///   - terminator: The string to message after all items have been printed. The default is a newline (`"\n"`).
    ///   - lineNum: The line in the source code of the function invoking the logger API. Defaults to the line of the function invoking this function.
    ///   - functionName: The name of the function invoking the logger API. Defaults to the name of the function invoking this function.
    ///   - fileName: The file containing the source code of the function invoking the logger API.
    ///               Defaults to the name of the file containing the function which invokes this function.
    class func exit(_ items: Any..., separator: String = " ", terminator: String = "\n", functionName: String = #function, lineNum: Int = #line, fileName: String = #file) {
        exit(message(items, separator, terminator), functionName: functionName, lineNum: lineNum, fileName: fileName)
    }
}
