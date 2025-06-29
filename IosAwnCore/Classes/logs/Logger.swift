//
//  Logger.shared.swift
//  awesome_notifications
//
//  Created by CardaDev on 01/04/22.
//

import Foundation
import os.log
import os

// Function for logging that works in both debug and release builds
// and ensures visibility in syslog
public func AWNLogger(type: String, className: String, message: String, line: Int = #line) {
    // Use NSLog which reliably writes to syslog in all build configurations
    if #available(iOS 14.0, *) {
        let osLogger = os.Logger(subsystem: "co.elfie.staging.app", category: "AWN-ELFIE")
        let logMessage = "\(message) [\(className)][\(line)]"
        
        switch type {
        case "ERROR":
            osLogger.error("\(logMessage)")
        case "WARNING":
            osLogger.warning("\(logMessage)")
        case "INFO":
            osLogger.info("\(logMessage)")
        default:
            osLogger.debug("\(logMessage)")
        }
    } else {
        NSLog("AWN-ELFIE/%@: %@", type, "\(message) [\(className)][\(line)]")
    }
}

public class Logger {
    public static let shared = LoggerImpl()
    private init() {}
}

// Define the Logger protocol
public protocol LoggerProtocol {
    func d(_ className: String, _ message: String, line: Int)
    func e(_ className: String, _ message: String, line: Int)
    func i(_ className: String, _ message: String, line: Int)
    func w(_ className: String, _ message: String, line: Int)
}

// Implement the Logger protocol in LoggerImpl class
public class LoggerImpl: LoggerProtocol {
    
    public func d(_ className: String, _ message: String, line: Int = #line) {
        AWNLogger(type: "DEBUG", className: className, message: message, line: line)
    }

    public func e(_ className: String, _ message: String, line: Int = #line) {
        AWNLogger(type: "ERROR", className: className, message: message, line: line)
    }

    public func i(_ className: String, _ message: String, line: Int = #line) {
        AWNLogger(type: "INFO", className: className, message: message, line: line)
    }

    public func w(_ className: String, _ message: String, line: Int = #line) {
        AWNLogger(type: "WARNING", className: className, message: message, line: line)
    }
}
