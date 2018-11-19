//
//  Logger.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import Foundation


enum LogType: String {
    case actionLog = "action_log"
    case playback = "playback"
    case error = "error"
    case warn = "warn"
    case uber = "uber"
}


class Logger {
    
    private static let shared = Logger()
    
    static func log(_ any: Any, logType: LogType) {
        self.log(any, logName: logType.rawValue)
    }
    
    static func log(_ any: Any, logName: String) {
        self.log("\(any)", logName: logName)
    }
    
    static func log(_ string: String, logName: String) {
        self.shared.log(string, logName: logName)
    }
    
    private func handle(for name: String) -> FileHandle {
        let fileName = NSHomeDirectory() + "/Documents/\(name)_log"
        var handle: FileHandle? = FileHandle(forWritingAtPath: fileName)
        if handle == nil {
            do {
                try "".write(
                    toFile: fileName,
                    atomically: true,
                    encoding: String.Encoding.utf8
                )
                handle = FileHandle(forWritingAtPath: fileName)
            } catch {}
        }
        return handle!
    }
    
    private func log(_ string: String, logName: String) {
        
//        #if DEVELOPMENT
//            if logName == LogType.error.rawValue
//                || logName == LogType.warn.rawValue {
//                print("\(logName): \(string)")
//            }
            //Wanna see all actions log for now 
            print("\(logName): \(string)")

        
            let handle = self.handle(for: logName)
            
            handle.seekToEndOfFile()
            let df = DateFormatter.USDateFormatter()
            df.dateFormat = "MMM dd, yyyy HH:mm:ss:SSS"
            let datestr = df.string(from: Date())
            if let data =  (datestr + " ").data(using: String.Encoding.utf8) {
                handle.write(data)
            }
            if let data = (string + "\n").data(using: String.Encoding.utf8) {
                handle.write(data)
            }
//        #endif
        
    }
    
}
