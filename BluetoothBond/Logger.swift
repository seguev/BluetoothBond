//
//  Logger.swift
//  BluetoothBond
//
//  Created by segev perets on 21/01/2024.
//

import Foundation
enum LogType {
    case error, warning, info
    var sign: String {
        switch self {
        case .info: "𝐢 "
        case .warning:"🚧 "
        case .error: "❌ "
        }
    }
}
class Logger {
    private init() {}
    static func log(_ type:LogType? = nil,_ items:Any...) {
    #if(DEBUG)
        let prefix = type?.sign ?? ""
        print(prefix,items,separator: ", ")
    #endif
    }
}
