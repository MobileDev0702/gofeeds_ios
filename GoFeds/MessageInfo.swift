//
//  Message.swift
//  CometChat
//
//  Created by Marin Benčević on 08/08/2019.
//  Copyright © 2019 marinbenc. All rights reserved.
//

import UIKit

struct MessageInfo {
    let content: String
    let avatar: String
    let isUser: Bool
}

extension MessageInfo {
    init(_ textMessage: String, avatar: String, user: Bool) {
        self.content = textMessage
        self.avatar = avatar
        self.isUser = user
  }
}
