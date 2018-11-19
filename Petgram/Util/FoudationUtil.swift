//
//  FoudationUtil.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import Foundation

// MARK: DateFormatter Extension

extension DateFormatter {
    
    static func USDateFormatter() -> DateFormatter {
        let locale = Locale(identifier: "en_US")
        let formatter = DateFormatter()
        formatter.locale = locale
        return formatter
    }
    
}


// MARK: URL Extension

extension URL {
    
    init?(path: String, params: [String: String]) {
        var paramStrs = [String]()
        for (k, var v) in params {
            v = v.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
            paramStrs += [k + "=" + "\(v)"]
        }
        let paramsStr = paramStrs.joined(separator: "&")
        let urlString = path + "?" + paramsStr
        
        self.init(string: urlString)
    }
    
    init?(stripString: String) {
        self.init(string: stripString.strip())
    }
    
}
