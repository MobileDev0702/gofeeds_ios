//
//  AlertConstants.swift
//  Imperial Beats
//
//  Created by Gaurav Tiwari on 28/12/17.
//  Copyright © 2017 Igniva Solutions Pvt Ltd. All rights reserved.
//

import Foundation

enum AlertTitle {
    case appName
    case interNet
    var value: String {
        switch self {
        case .appName: return "GoFeds"
        case .interNet: return "No Internet Connection"
        }
    }
}

enum Messages {
    case custom(String)
    
    var value: String {
        switch self {
        case .custom(let message) : return message
        }
    }
}
enum AlertButtonTitle {
    case ok, cancel, delete
    
    var value: String {
        switch self {
        case .ok: return "OK"
        case .cancel: return "Cancel"
        case .delete: return "Delete"
        }
    }
}

