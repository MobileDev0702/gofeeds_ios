//
//  Message.swift
//  GoFeds
//

import Foundation
import UIKit
import Firebase

class MessageModel: NSObject {
    
    var fromId : String?
    var text : String?
    var timeStamp : NSNumber?
    var toId : String?
    
    func chatPartnerId() -> String? {
        
        return fromId == LoginSession.getValueOf(key: SessionKeys.fToken) ? toId : fromId
        
    }
        
        
}
