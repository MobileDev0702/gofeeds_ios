//
//  GoFedsConstants.swift
//  GoFeds
//
//  Created by Inderveer Singh on 02/06/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let timeToStopValueListener = 5
}

let timeToStopValueListener = 5

struct GoFedsFirebase {
    static let databaseURL = "https://gofeds-8ddce.firebaseio.com/Chats/3jeudO6qYuW2tGM8zr9Z"
    static let realTimeDatabaseURL = "https://gofeds-8ddce.firebaseio.com/"
}

struct NotificationKeys {
    static let desiredPorts = "DesiredPort_Key"
}
extension Notification.Name {
    static let updateDesiredPorts = Notification.Name("updateDesiredPorts")
    static let forumAnswer = Notification.Name("submitForumAnswer")
}

//MARK:- Session Keys(User Defaults)
struct SessionKeys {
    
    static let showId = "Key_user_id"
    static let userName = "Key_user_name"
    static let email = "Key_user_email"
    static let desiredPort = "Key_desiredPort"
    static let rank = "Key_rank"
    static let agency = "Key_agency"
    static let currentPort = "Key_currentPort"
    static let fToken = "Key_fToken"
    static let office = "Key_office"
    
}

struct ChatKeys {
    static let message = "message"
    static let userId = "userId"
    static let id = "id"
    static let timestamp = "timestamp"
    static let deleteForUser = "deleteForUser"
    static let currentPort = "Key_currentPort"
    static let fToken = "Key_fToken"
    static let office = "Key_office"
    static let deleted = "deleted"
}

struct ConversationKeys {
    static let creatorId = "creatorId"
    static let receiverId = "receiverId"
    static let senderId = "senderId"
    static let chatDeletedForUser = "chatDeletedForUser"
    static let otherConversationId = "otherConversationId"
    static let conversationId = "conversationId"
    static let deleted = "deleted"
    static let messageId = "messageId"
    static let lastMessage = "lastMessage"
    static let lastMessageTimeStamp = "lastMessageTimeStamp"
    static let isRead = "isRead"
    static let timestamp = "timestamp"
    static let conversations = "conversations"
    static let creatorUser = "creatorUser"
    static let receiverUser = "receiverUser"
}

struct FirebaseKeys {
    static let messages = "messages"
    static let users = "users"
    static let chatUsers = "chatUsers"
    static let conversations = "conversations"
}

struct LocalNotificationKeys {
    static let singleMessagesFetched = "singleMessagesFetched"
    static let conversationsFetched = "conversationsFetched"
    static let messageUpdated = "messageUpdated"
    static let conversations = "conversations"
}
