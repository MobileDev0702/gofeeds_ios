//
//  Message.swift
//  CSS POS
//
//  Created by intersoft-admin on 21/09/18.
//  Copyright © 2018 intersoft-kansal. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth
import MessageKit

enum MessageOwner
{
    case sender
    case receiver
}

class Message: MessageType
{
    //MARK: Properties
    var owner: MessageOwner
    var deletedForUsers: [String: Bool]?
    
    var deleted: NSNumber
    var msg: String
    var id: String
  //  var messageType: NSNumber
    var timeStamp: NSNumber
   // var translated: Bool
    var userId: String
 //   var userName: String
    var isMsgDeletedForCurrentUser: Bool = false
    
    init(_ message: [String: NSObject])
    {
        deletedForUsers = message[ChatKeys.deleteForUser] as? [String : Bool]
        deleted = message[ChatKeys.deleted]?.num() ?? 0
        //language = message[keys.language]?.string() ?? ""
        msg = message[ChatKeys.message]?.string() ?? ""
        id = message[ChatKeys.id]?.string() ?? ""
    /// messageType = message[keys.messageType]?.num() ?? 0
        timeStamp = message[ChatKeys.timestamp]?.num() ?? 0
       // translated = message[keys.translated] as? Bool ?? false
        userId = message[ChatKeys.userId]?.string() ?? ""
      //  userName = message[keys.userName]?.string() ?? ""
        
        if userId == LoginSession.currentUserId
        {
            owner = .sender
        }
        else
        {
            owner = .receiver
        }
        
        self.updateDeletedForCurrentUser()
    }
    
    var sender: SenderType {
        return senderType.init(userId)
    }
    var messageId: String {
        return id
    }
    var sentDate: Date {
        return Date.dateFromTimeInterval(timeStamp).date()
    }
    var kind: MessageKind {
        return .text(msg)
    }
    
    func updateDeletedForCurrentUser()
    {
        for (key, value) in (deletedForUsers)!
        {
            print("Key", key)
            print("Value", value)
            
            if key == LoginSession.currentUserId && value == true
            {
                isMsgDeletedForCurrentUser = true
            }
        }
    }
//
//    func updateMessage(_ message: [String: NSObject])
//    {
//        let keys = Constants.Message()
//        
//        deletedForUsers = message[keys.deleteForUser] as? [String : Bool]
//        deleted = message[keys.deleted]?.num() ?? 0
//        language = message[keys.language]?.string() ?? ""
//        msg = message[keys.message]?.string() ?? ""
//        messageId = message[keys.messageId]?.string() ?? ""
//        messageType = message[keys.messageType]?.num() ?? 0
//        timeStamp = message[keys.timestamp]?.num() ?? 0
//        translated = message[keys.translated] as? Bool ?? false
//        userId = message[keys.userID]?.string() ?? ""
//        userName = message[keys.userName]?.string() ?? ""
//        
//        if userId == (Auth.auth().currentUser?.uid)!
//        {
//            owner = .sender
//        }
//        else
//        {
//            owner = .receiver
//        }
//        
//        self.updateDeletedForCurrentUser()
//    }
    
    //MARK: Methods
    
    class func sendMessageToUser(_ toId: NSNumber, _ message: String, completion: @escaping (Bool) -> Swift.Void)
    {
        var deletedForUsers:[String: Bool] = [:]
        
        deletedForUsers.updateValue(false, forKey: toId.stringValue)
        deletedForUsers.updateValue(false, forKey: LoginSession.currentUserId)
        
        Message.addOrUpdateConversation(toId, message) { (status, msgRef, msgId, timeStamp, otherConvId) in
            
            let messageDict = [ChatKeys.deleteForUser: deletedForUsers, ChatKeys.deleted: 0, ChatKeys.message: message, ChatKeys.id: msgId, ChatKeys.timestamp: timeStamp, ChatKeys.userId: LoginSession.currentUserId] as [String : Any]
            
            Message.uploadMessage(msgRef, withValues: messageDict) { (status) in
                
                if otherConvId.count > 0
                {
                    var otherMsgRef = self.getMessageRef(otherConvId)
                    
                    otherMsgRef = otherMsgRef.child(msgId)
                    
                    Message.uploadMessage(otherMsgRef, withValues: messageDict) { (status) in
                        
                        completion(status)
                    }
                }
                else
                {
                    completion(status)
                }
            }
        }
    }
    
    class func addOrUpdateConversation(_ toID: NSNumber, _ message: String, completion: @escaping (Bool, DatabaseReference, String, Int64, String) -> Swift.Void)
    {
        let senderID = LoginSession.currentUserId.nsnumValue()
        
        let chatUsersRef = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.chatUsers).child(senderID.stringValue)
        
        var chatUsersRefHanlde = 0 as UInt
        chatUsersRefHanlde = chatUsersRef.observe(.value) { (snapshot) in
            chatUsersRef.removeObserver(withHandle: chatUsersRefHanlde)
            
            if snapshot.exists()
            {
                if let snapValue = snapshot.value as? [String: NSObject]
                {
                    let allConversations = (snapValue.values)
                    
                    var isConversationFound = false
                    
                    // Check if conversation with user exists or not
                    for conversation in allConversations
                    {
                        var convDict = conversation as! Dictionary<String, NSObject> as Dictionary
                        
                        if (((convDict[ConversationKeys.creatorId])?.num() == senderID && (convDict[ConversationKeys.receiverId])?.num() == toID) || (convDict[ConversationKeys.creatorId]?.num() == toID && convDict[ConversationKeys.receiverId]?.num() == senderID))
                        {
                            isConversationFound = true
                            
                            // Means both user had chatted but conversation deleted by receiver (toCahsierId)
                            if convDict[ConversationKeys.chatDeletedForUser]?.num() == toID
                            {
                                convDict.updateValue(0 as NSObject, forKey: ConversationKeys.chatDeletedForUser)
                                
                                // Create New conversation ID for Receiver
                                let newConvIdForReceiver = getConversationRefAndConvId(toID)
                                convDict.updateValue(newConvIdForReceiver as NSObject, forKey: ConversationKeys.otherConversationId)
                            }
                            
                            // Conversation with User found. Update existing Conversation with Last message
                            let msgRefAndMsgId = getMessageRefAndMsgId(convDict[ConversationKeys.conversationId] as! String)
                            let msgId = msgRefAndMsgId.1
                            
                            convDict.updateValue(0 as NSObject, forKey: ConversationKeys.deleted)
                            convDict.updateValue(msgId as NSObject, forKey: ConversationKeys.messageId)
                            convDict.updateValue(message as NSObject, forKey: ConversationKeys.lastMessage)
                            convDict.updateValue(Date.currentTimerIntervalGMT() as NSObject, forKey: ConversationKeys.lastMessageTimeStamp)
                            convDict.updateValue(senderID as NSObject, forKey: ConversationKeys.senderId)
                            
                            chatUsersRef.child(convDict[ConversationKeys.conversationId] as! String).setValue(convDict)
                            
                            //// Update Conversation For Receiver
                            
                            // Means both user had chatted but conversation deleted by receiver (toCahsierId)
                            if convDict[ConversationKeys.chatDeletedForUser]?.num() == toID || (convDict[ConversationKeys.otherConversationId]?.string().count)! > 0
                            {
                                // reverse convId and Other ConvId for receiver
                                let convId = convDict[ConversationKeys.conversationId]
                                convDict.updateValue(convDict[ConversationKeys.otherConversationId]!, forKey: ConversationKeys.conversationId)
                                convDict.updateValue(convId!, forKey: ConversationKeys.otherConversationId)
                            }
                            
                            // Update
                            ConversationManager.shared.updateConversationForReceiver(convDict, toID, ({
                                
                                if convDict[ConversationKeys.chatDeletedForUser]?.num() == toID || (convDict[ConversationKeys.otherConversationId]?.string().count)! > 0
                                {
                                    completion(true, msgRefAndMsgId.0, msgId, convDict[ConversationKeys.lastMessageTimeStamp] as! Int64, convDict[ConversationKeys.conversationId] as! String)
                                }
                                else
                                {
                                    completion(true, msgRefAndMsgId.0, msgId, convDict[ConversationKeys.lastMessageTimeStamp] as! Int64, "")
                                }
                            }))
                            
                            break
                        }
                    }
                    
                    print("Code after For loop >>>", isConversationFound)
                    
                    if !isConversationFound
                    {
                        Message.updateConversationForNewUser(chatUsersRef, toID, message, completion: completion)
                    }
                }
            }
                // Means not chatted with anyone yet
            else
            {
                Message.updateConversationForNewUser(chatUsersRef, toID, message, completion: completion)
            }
        }
    }
    
    // Start Chat with User
    class func updateConversationForNewUser(_ chatUsersRef: DatabaseReference, _ toID: NSNumber, _ message: String, completion: @escaping (Bool, DatabaseReference, String, Int64, String) -> Swift.Void)
    {
        let senderID = LoginSession.currentUserId
        
        var conversationDict = [ConversationKeys.chatDeletedForUser: 0, ConversationKeys.conversationId: "", ConversationKeys.creatorId: senderID, ConversationKeys.receiverId: toID, ConversationKeys.deleted: 0, ConversationKeys.isRead: 1, ConversationKeys.lastMessage: message, ConversationKeys.lastMessageTimeStamp: Date.currentTimerIntervalGMT(), ConversationKeys.messageId: "", ConversationKeys.otherConversationId: "", ConversationKeys.senderId: senderID, ConversationKeys.timestamp: Date.currentTimerIntervalGMT()] as [String : Any]
        
        var chatUsersRef = chatUsersRef
        chatUsersRef = chatUsersRef.childByAutoId()
        
        let conversationID = chatUsersRef.url.components(separatedBy: "/").last
        let msgRefAndMsgId = getMessageRefAndMsgId(conversationID!)
        let msgId = msgRefAndMsgId.1
        
        conversationDict.updateValue(conversationID ?? "", forKey: ConversationKeys.conversationId)
        conversationDict.updateValue(msgId, forKey: ConversationKeys.messageId)
        
        chatUsersRef.setValue(conversationDict)
        
        //// Update Conversation For Receiver
        ConversationManager.shared.updateConversationForReceiver(conversationDict, toID, ({
            
            completion(true, msgRefAndMsgId.0, msgId, conversationDict[ConversationKeys.lastMessageTimeStamp] as! Int64, "")
        }))
    }
    
    class func getMessageRefAndMsgId(_ conversationID: String) -> (DatabaseReference, String)
    {
        let messagesDbRef = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.conversations).child(conversationID).childByAutoId()
        
        let messageId = messagesDbRef.url.components(separatedBy: "/").last
        
        return (messagesDbRef, messageId!)
    }
    
    class func getMessageRef(_ conversationID: String) -> DatabaseReference
    {
        let messagesDbRef = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.conversations).child(conversationID)
        
        return messagesDbRef
    }
    
    
    class func getConversationRefAndConvId(_ userId: NSNumber) -> String
    {
        let chatUsersRef = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.chatUsers).child(userId.stringValue).childByAutoId()
        
        let convID = chatUsersRef.url.components(separatedBy: "/").last
        
        return convID!
    }
    
    class func uploadMessage(_ messagesDbRef: DatabaseReference, withValues: [String: Any], completion: @escaping (Bool) -> Swift.Void)
    {
        messagesDbRef.setValue(withValues, withCompletionBlock: { (error, _) in
            if error == nil {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
//    class func uploadMessageInGroup(withValues: [String: Any], completion: @escaping (Bool) -> Swift.Void)
//    {
//        var withValues = withValues
//
//        let keys = Constants.Message()
//
//        let messagesDbRef = Database.database().reference().child(FirebaseKeys.messages).child((LoginModel.shared?.distInfo?.distributorID)!).child(FirebaseKeys.groupChat).childByAutoId()
//
//        let messageId = messagesDbRef.url.components(separatedBy: "/").last
//
//        withValues.updateValue(messageId ?? "", forKey: keys.messageId)
//
//        messagesDbRef.setValue(withValues)
//
//    }
    
    //MARK: Methods
    
    class func markMessagesRead(_ convID: String)
    {
        let senderID = LoginSession.currentUserId
        
        let ref = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.chatUsers).child(senderID).child(convID)
        
        var refHanlde = 0 as UInt
        refHanlde = ref.observe(.value) { (snap) in
            ref.removeObserver(withHandle: refHanlde)
            
            if snap.exists() {
                
                // print(snap.value ?? "")
                
                var conv = snap.value as! [String: Any]
                
                // print(conv)
                
                conv.updateValue(1, forKey: ConversationKeys.isRead)
                
                ref.setValue(conv)
            }
        }
        
    }
    
    //MARK: DELETE MESSAGES
//    func deleteGroupMessage()
//    {
//        let ref = Database.database().reference().child(FirebaseKeys.messages).child((LoginModel.shared?.distInfo?.distributorID)!).child(FirebaseKeys.groupChat).child(self.messageId)
//
//        if self.userId == Auth.auth().currentUser?.uid
//        {
//            self.deleted = 1
//        }
//        else
//        {
//            deletedForUsers?.updateValue(true, forKey: (LoginModel.shared?.distInfo?.cashierId)!)
//            self.updateDeletedForCurrentUser()
//        }
//
//        let keys = Constants.Message()
//
//        let messageDict = [keys.deleteForUser: self.deletedForUsers ?? "", keys.deleted: self.deleted, keys.language: self.language, keys.message: self.msg, keys.messageId: self.messageId, keys.messageType: self.messageType, keys.timestamp: self.timeStamp, keys.translated: self.translated, keys.userID: self.userId, keys.userName: self.userName] as [String : Any]
//
//        ref.setValue(messageDict)
//    }
    
    func deleteSingleMessage(_ conversationHandler: ConversationHandler?, _ isLastMsg: Bool)
    {
        let ref = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.conversations).child((conversationHandler?.conversation?.conversationId)!).child(self.messageId)
        
        if self.userId == Auth.auth().currentUser?.uid
        {
            self.deleted = 1
        }
        else
        {
            deletedForUsers?.updateValue(true, forKey: LoginSession.currentUserId)
            self.updateDeletedForCurrentUser()
        }
                
        let messageDict = [ChatKeys.deleteForUser: deletedForUsers ?? "", ChatKeys.deleted: self.deleted, ChatKeys.message: self.msg, ChatKeys.id: self.messageId, ChatKeys.timestamp: self.timeStamp, ChatKeys.userId: self.userId] as [String : Any]
        
        ref.setValue(messageDict) { (error, ref) in
            
            if error == nil
            {
                if(isLastMsg)
                {
                    if self.userId == Auth.auth().currentUser?.uid && (conversationHandler?.conversation?.otherConversationId.count)! > 0
                    {
                        self.deleteMsgForOtherUser((conversationHandler?.conversation?.otherConversationId)!, messageDict, completion: { () in
                            
                            self.updateLastMessageinConversation(conversationHandler)
                        })
                    }
                    else
                    {
                        self.updateLastMessageinConversation(conversationHandler)
                    }
                }
            }
        }
    }
    
    func deleteMsgForOtherUser(_ conversationId: String, _ messageDict: [String: Any], completion: @escaping () -> Swift.Void)
    {
        let ref = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.conversations).child(conversationId).child(self.messageId)
        
        ref.setValue(messageDict) { (error, ref) in
            
            if error == nil
            {
                completion()
            }
        }
    }
    
    func updateLastMessageinConversation(_ conversationHandler: ConversationHandler?)
    {
        let conversationRef = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.chatUsers).child(LoginSession.currentUserId).child((conversationHandler?.conversation?.conversationId)!)
        
        var conversationRefHanlde = 0 as UInt
        conversationRefHanlde = conversationRef.observe(.value) { (snapshot) in
            conversationRef.removeObserver(withHandle: conversationRefHanlde)
            
            if var conversationDetails = snapshot.value as? [String: NSObject]
            {
                if self.userId == Auth.auth().currentUser?.uid
                {
                    conversationDetails.updateValue(1 as NSObject, forKey: ConversationKeys.deleted)
                }
                    
                else
                {
                    let lastMessage = conversationHandler?.getLastMessage()
                    
                    if lastMessage == nil
                    {
                        conversationDetails.updateValue("" as NSObject, forKey: ConversationKeys.lastMessage)
                        conversationDetails.updateValue(0 as NSObject, forKey: ConversationKeys.lastMessageTimeStamp)
                        conversationDetails.updateValue("" as NSObject, forKey: ConversationKeys.messageId)
                        conversationDetails.updateValue(conversationDetails[ConversationKeys.creatorId]!, forKey: ConversationKeys.senderId)
                    }
                    else
                    {
                        conversationDetails.updateValue((lastMessage?.msg ?? "") as NSObject, forKey: ConversationKeys.lastMessage)
                        conversationDetails.updateValue((lastMessage?.timeStamp)!, forKey: ConversationKeys.lastMessageTimeStamp)
                        
                        let msgId = lastMessage?.messageId ?? ""
                        
                        conversationDetails.updateValue(msgId as NSObject, forKey: ConversationKeys.messageId)
                        
                        if lastMessage?.userId == Auth.auth().currentUser?.uid
                        {
                            conversationDetails.updateValue((LoginSession.currentUserId.nsnumValue()) as NSObject, forKey: ConversationKeys.senderId)
                        }
                        else
                        {
                            let otherUserId = self.getOtherUserIdFromConversation(conversationDetails)
                            conversationDetails.updateValue(otherUserId as NSObject, forKey: ConversationKeys.senderId)
                        }
                    }
                }
                
                conversationRef.setValue(conversationDetails, withCompletionBlock: { (error, ref) in
                    
                    if error == nil && self.userId == Auth.auth().currentUser?.uid
                    {
                        self.updateLastMessageInOtheruserConversation(conversationDetails)
                    }
                })
            }
        }
    }
    
    func getOtherUserIdFromConversation(_ conversation: [String: NSObject]) -> NSNumber
    {
        if conversation[ConversationKeys.creatorId]?.string() == LoginSession.currentUserId
        {
            return (conversation[ConversationKeys.receiverId]?.num())!
        }
        else
        {
            return (conversation[ConversationKeys.creatorId]?.num())!
        }
    }
    
    func updateLastMessageInOtheruserConversation(_ convDetails: [String: NSObject])
    {
        let currentUserId = LoginSession.currentUserId.nsnumValue()
        let otherUserId = self.getOtherUserIdFromConversation(convDetails)
                
        let chatUsersRef = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.chatUsers).child(otherUserId.stringValue)
        
        var chatUsersRefHanlde = 0 as UInt
        chatUsersRefHanlde = chatUsersRef.observe(.value) { (snapshot) in
            chatUsersRef.removeObserver(withHandle: chatUsersRefHanlde)
            
            if snapshot.exists()
            {
                if let snapValue = snapshot.value as? [String: NSObject]
                {
                    let allConversations = (snapValue.values)
                    
                    print("All Conversations >>>", allConversations)
                    
                    // Check if conversation with user exists or not
                    for conversation in allConversations
                    {
                        var convDict = conversation as! Dictionary<String, NSObject> as Dictionary
                        
                        if ((((convDict[ConversationKeys.creatorId])?.num())! == otherUserId && (convDict[ConversationKeys.receiverId]?.num())! == currentUserId) || (convDict[ConversationKeys.creatorId]?.num() == currentUserId && convDict[ConversationKeys.receiverId]?.num() == otherUserId))
                        {
                            convDict.updateValue(convDetails[ConversationKeys.deleted]!, forKey: ConversationKeys.deleted)
                            
                            print("conversation ID 2 >>>>", convDict[ConversationKeys.conversationId] ?? "")
                            
                            chatUsersRef.child(convDict[ConversationKeys.conversationId] as! String).setValue(convDict)
                            
                            break
                        }
                    }
                }
            }
        }
    }
}

class senderType: SenderType {
    
    var idd: String
    
    init(_ id: String) {
        idd = id
    }
    
    var displayName: String {
        return ""
    }
    
    var senderId: String {
        return idd
    }
}


