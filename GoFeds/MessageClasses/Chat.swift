//
//  Chat.swift
//  My YOGA
//
//  Created by Tarun Sachdeva on 15/05/20.
//  Copyright © 2020 Manisha Kohlii. All rights reserved.
//

import Foundation
import UIKit

struct Chat {
    var users: [String]
    
    var dictionary: [String: Any] {
        return ["users": users]
    }
}


extension Chat {
    init?(dictionary: [String:Any]) {
        guard let chatUsers = dictionary["users"] as? [String] else {return nil}
        self.init(users: chatUsers)
    }
}
