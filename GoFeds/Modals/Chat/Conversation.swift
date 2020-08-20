//
//  Conversation.swift
//  CSS POS
//
//  Created by intersoft-admin on 21/09/18.
//  Copyright © 2018 intersoft-kansal. All rights reserved.
//

import Foundation
import FirebaseAuth

class Conversation
{
    var chatDeletedForUser: NSNumber
    var conversationId: String
    var creatorId: NSNumber
    var creatorUser: String
    var deleted: NSNumber
    var isRead: NSNumber
    var lastMessageTimeStamp: NSNumber
    {
        didSet
        {
            ConversationManager.shared.sortConversationsArr()
        }
    }
    
    var messageId: String
    var otherConversationId: String
    var receiverId: NSNumber
    var receiverUser: String
    var senderId: NSNumber
    var timeStamp: NSNumber
    var displayName: String
    var lastMessage: String
    
    init(_ conversation: [String: NSObject])
    {
        chatDeletedForUser = conversation[ConversationKeys.chatDeletedForUser]?.num() ?? 0
        conversationId = conversation[ConversationKeys.conversationId] as? String ?? ""
        creatorId = conversation[ConversationKeys.creatorId]?.num() ?? 0
        creatorUser = conversation[ConversationKeys.creatorUser] as? String ?? ""
        deleted = conversation[ConversationKeys.deleted]?.num() ?? 0
        isRead = conversation[ConversationKeys.isRead]?.num() ?? 0
        lastMessageTimeStamp = conversation[ConversationKeys.lastMessageTimeStamp]?.num() ?? 0
        messageId = conversation[ConversationKeys.messageId]?.string() ?? ""
        otherConversationId = conversation[ConversationKeys.otherConversationId]?.string() ?? ""
        receiverId = conversation[ConversationKeys.receiverId]?.num() ?? 0
        receiverUser = conversation[ConversationKeys.receiverUser]?.string() ?? ""
        senderId = conversation[ConversationKeys.senderId]?.num() ?? 0
        timeStamp = conversation[ConversationKeys.timestamp]?.num() ?? 0
        lastMessage = conversation[ConversationKeys.lastMessage] as? String ?? ""
        
        if creatorId.stringValue == LoginSession.currentUserId
        {
            displayName = receiverUser
        }
        else
        {
            displayName = creatorUser
        }
    }
    
    func updateConversation(_ conversation: [String: NSObject])
    {
        chatDeletedForUser = conversation[ConversationKeys.chatDeletedForUser]?.num() ?? 0
        conversationId = conversation[ConversationKeys.conversationId] as? String ?? ""
        creatorId = conversation[ConversationKeys.creatorId]?.num() ?? 0
        creatorUser = conversation[ConversationKeys.creatorUser] as? String ?? ""
        deleted = conversation[ConversationKeys.deleted]?.num() ?? 0
        isRead = conversation[ConversationKeys.isRead]?.num() ?? 0
        lastMessageTimeStamp = conversation[ConversationKeys.lastMessageTimeStamp]?.num() ?? 0
        messageId = conversation[ConversationKeys.messageId]?.string() ?? ""
        otherConversationId = conversation[ConversationKeys.otherConversationId]?.string() ?? ""
        receiverId = conversation[ConversationKeys.receiverId]?.num() ?? 0
        receiverUser = conversation[ConversationKeys.receiverUser]?.string() ?? ""
        senderId = conversation[ConversationKeys.senderId]?.num() ?? 0
        timeStamp = conversation[ConversationKeys.timestamp]?.num() ?? 0
        lastMessage = conversation[ConversationKeys.lastMessage] as? String ?? ""
        
        print("LAst message >>>>>>", lastMessage)
        
        if creatorId.stringValue == LoginSession.currentUserId
        {
            displayName = receiverUser
        }
        else
        {
            displayName = creatorUser
        }
    }
}
