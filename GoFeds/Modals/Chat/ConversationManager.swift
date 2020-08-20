//
//  ConversationManager.swift
//  POSAPP
//
//  Created by intersoft-admin on 08/10/18.
//  Copyright © 2018 intersoft-kansal. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ConversationManager
{
    static let shared = ConversationManager()
    
    private var conversationValueRef: DatabaseReference!
    private var conversationAddedRef: DatabaseReference!
    private var conversationRemovedRef: DatabaseReference!
    private var shouldObserveAddChild: Bool = false
    private var timerToRemoveValueListener: Timer? = nil
    private var databaseHandle: DatabaseHandle? = nil
    
    var conversationsArr: [ConversationHandler] = []
    
    func sortConversationsArr()
    {
        if(ConversationManager.shared.conversationsArr.count > 0)
        {
            ConversationManager.shared.conversationsArr.sort {
                ($0.conversation?.lastMessageTimeStamp.intValue ?? 0) > ($1.conversation?.lastMessageTimeStamp.intValue ?? 0)
            }
        }
    }
    
    func getAllConversations()
    {
        if conversationAddedRef == nil
        {
            conversationValueRef = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.chatUsers).child(LoginSession.currentUserId)
            
            databaseHandle = conversationValueRef.observe(.value, with: { (snap) in
                
                if snap.exists()
                {
                    print("Converastions == \(snap)")
                    
                    self.conversationsArr(snap.value as? [String : NSObject] ?? [:])
                   NotificationCenter.default.post(name: NSNotification.Name(rawValue: LocalNotificationKeys.conversationsFetched), object: self.conversationsArr)
                }
                
                if self.timerToRemoveValueListener == nil
                {
                    self.timerToRemoveValueListener = Timer.scheduledTimer(timeInterval: TimeInterval(Constants.timeToStopValueListener), target: self, selector: #selector(self.removeValueListnerAndAddOther), userInfo: nil, repeats: false)
                }
            })
            
            self.newConversationAdded()
            self.conversationRemoved()
        }
        else
        {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: LocalNotificationKeys.conversationsFetched), object: self.conversationsArr)
        }
    }
    
    @objc func removeValueListnerAndAddOther()
    {
        conversationValueRef.removeObserver(withHandle: databaseHandle!)
        timerToRemoveValueListener?.invalidate()
        timerToRemoveValueListener = nil
        self.shouldObserveAddChild = true
    }
    
    func newConversationAdded()
    {
        conversationAddedRef = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.chatUsers).child(LoginSession.currentUserId)
        
        conversationAddedRef.observe(.childAdded) { (snap) in
            
            if snap.exists() && self.shouldObserveAddChild
            {
                print("Group Messages == \(snap)")
                self.conversationAddedArr(snap.value as! [String: NSObject])
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: LocalNotificationKeys.conversationsFetched), object: self.conversationsArr)
            }
        }
    }
    
    func conversationRemoved()
    {
        conversationRemovedRef = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.chatUsers).child(LoginSession.currentUserId)
        
        conversationRemovedRef.observe(.childRemoved) { (snap) in
            
            print("Conversation deleted == \(snap)")
            
            if snap.exists()
            {
                let conversation = ConversationManager.shared.getConversation(snap.value as! [String : NSObject])
                ConversationManager.shared.removeConversation(conversation!)
                conversation?.removeConversationHandlerObservers()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: LocalNotificationKeys.conversationsFetched), object: self.conversationsArr)
            }
        }
    }
    
    private func conversationsArr(_ info: [String: NSObject])
    {
        for (_, value) in info
        {
            let conversation = ConversationManager.shared.getConversation(value as! [String : NSObject])
            
            if conversation == nil
            {
                ConversationManager.shared.addConversation(value as! [String : NSObject])
            }
        }
        
        self.sortConversationsArr()
    }
    
    private func conversationAddedArr(_ info: [String: NSObject])
    {
        let conversation = ConversationManager.shared.getConversation(info)
        
        if conversation == nil
        {
            ConversationManager.shared.addConversation(info)
        }
        
        if(ConversationManager.shared.conversationsArr.count > 0)
        {
            ConversationManager.shared.conversationsArr.sort {
                ($0.conversation?.lastMessageTimeStamp.intValue ?? 0) < ($1.conversation?.lastMessageTimeStamp.intValue ?? 0)
            }
        }
    }
    
    deinit
    {
        print("Conversation Manager deallocated")
    }
}

extension ConversationManager
{
    func removeConversationManagerObservers()
    {
        if conversationAddedRef != nil
        {
            conversationAddedRef.removeAllObservers()
            conversationAddedRef = nil
        }
        
        for conversation in conversationsArr
        {
            conversation.removeConversationHandlerObservers()
        }
        
        conversationsArr.removeAll()
    }
    
    //When Coversation Deleted, then need to remove from array
    func removeConversation(_ objToRemove: ConversationHandler)
    {
        for handlerIndex in 0 ..< conversationsArr.count
        {
            let conversationHandler = conversationsArr[handlerIndex]
            
            if conversationHandler.conversation?.conversationId == objToRemove.conversation?.conversationId
            {
                print("Removing Conversation Object == ", conversationHandler.conversation?.conversationId ?? 0)
                conversationsArr.remove(at: handlerIndex)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: LocalNotificationKeys.conversationsFetched), object: self.conversationsArr)
                
                break
            }
        }
    }
}

extension ConversationManager
{
    private func getConversation(_ details: [String : NSObject]) -> ConversationHandler?
    {
        var conversationHandlerFound: Bool = false
        let conversationIdToFind = details[ConversationKeys.conversationId] as? String ?? ""

        for conversationHandler in conversationsArr
        {
            if conversationHandler.conversation?.conversationId == conversationIdToFind
            {
                conversationHandlerFound = true
                return conversationHandler
            }
        }

        if conversationHandlerFound == false
        {
            return nil
        }
    }
    
    private func addConversation(_ details: [String : NSObject])
    {
        let newHandler = ConversationHandler(details)
        conversationsArr.append(newHandler)
    }
    
    func getConversationForUser(_ userId: NSNumber) -> ConversationHandler?
    {
        for conversation in conversationsArr
        {
            if conversation.conversation?.creatorId == userId || conversation.conversation?.receiverId == userId
            {
                return conversation
            }
        }
        
        return nil
    }
}

extension ConversationManager
{
    func checkAndCreateNewConversation(_ toID: NSNumber, _ toName: String, _ completion: @escaping () -> Swift.Void)
    {
        // First check if Conversation exits for Sender
        ConversationManager.shared.getConversationIDIfAlredyExits(LoginSession.currentUserId.num(), toID, completion: { (convID) in
            
            if convID == ""
            {
                // Check if Conversation exists for receiver
                ConversationManager.shared.getConversationIDIfAlredyExits(toID, LoginSession.currentUserId.num(), completion: { (otherConvId) in
                    
                    // If otherConvId = nil  Means conversation not exists in past with Receiver
                    // else  Means conversation exists in past with Receiver, In this case we need to create conversation with other converastion id
                    
                    self.createConverstaionWithoutMsg(toID, toName, otherConvId, completion: completion)
                })
            }
            else
            {
                completion()
            }
        })
    }
    
    func createConverstaionWithoutMsg(_ toId: NSNumber, _ toName: String, _ otherConversationId: String, completion: @escaping () -> Swift.Void)
    {
        let senderID = LoginSession.currentUserId.nsnumValue()
        
        var conversationDict = [ConversationKeys.chatDeletedForUser: 0, ConversationKeys.conversationId: "", ConversationKeys.creatorId: senderID, ConversationKeys.receiverId: toId, ConversationKeys.creatorUser: LoginSession.getValueOf(key: SessionKeys.userName), ConversationKeys.deleted: 0, ConversationKeys.isRead: 1, ConversationKeys.lastMessage: "", ConversationKeys.lastMessageTimeStamp: Date.currentTimerIntervalGMT(), ConversationKeys.messageId: "", ConversationKeys.otherConversationId: otherConversationId, ConversationKeys.receiverUser: toName, ConversationKeys.senderId: senderID, ConversationKeys.timestamp: Date.currentTimerIntervalGMT()] as [String : Any]
        
        //ConversationKeys.creatorUser: LoginSession.getValueOf(key: SessionKeys.userName) ?? "",
        //ConversationKeys.receiverUser: ""
        
        let chatUsersRef = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.chatUsers).child(senderID.stringValue).childByAutoId()
        
        let conversationID = chatUsersRef.url.components(separatedBy: "/").last
        conversationDict.updateValue(conversationID ?? "", forKey: ConversationKeys.conversationId)
        
        chatUsersRef.setValue(conversationDict)
        
        if otherConversationId.count > 0
        {
            // reverse convId and Other ConvId for receiver
            let convId = conversationDict[ConversationKeys.conversationId]
            conversationDict.updateValue(conversationDict[ConversationKeys.otherConversationId]!, forKey: ConversationKeys.conversationId)
            conversationDict.updateValue(convId!, forKey: ConversationKeys.otherConversationId)
        }
        
        ConversationManager.shared.updateConversationForReceiver(conversationDict, toId, completion)
    }
    
    func getConversationIDIfAlredyExits(_ cashIdToFound: NSNumber,_ otherCashId: NSNumber, completion: @escaping (String) -> Swift.Void)
    {
        let chatUsersRef = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.chatUsers).child(cashIdToFound.stringValue)
        
        var conversationID = ""
        var chatUsersRefHanlde = 0 as UInt
        chatUsersRefHanlde = chatUsersRef.observe(.value) { (snapshot) in
            
            chatUsersRef.removeObserver(withHandle: chatUsersRefHanlde)
            if snapshot.exists()
            {
                if let snapValue = snapshot.value as? [String: NSObject]
                {
                    let allConversations = (snapValue.values)
                    
                    // Check if conversation with user exists or not
                    for conversation in allConversations
                    {
                        let convDict = conversation as! Dictionary<String, NSObject> as Dictionary
                        
                        if ((((convDict[ConversationKeys.creatorId])?.num())! == cashIdToFound && (convDict[ConversationKeys.receiverId]?.num())! == otherCashId) || (convDict[ConversationKeys.creatorId]?.num() == otherCashId && convDict[ConversationKeys.receiverId]?.num() == cashIdToFound))
                        {
                            conversationID = convDict[ConversationKeys.conversationId] as! String
                            
                            break
                        }
                    }
                }
            }
            
            print("Conversation ID>>>>", conversationID)
            
            completion(conversationID)
        }
    }
    
    func updateConversationForReceiver(_ conversationDict: [String: Any], _ toID: NSNumber, _ completion: @escaping () -> Swift.Void)
    {
       // let keys = Constants.Conversation()
        
        var convDict = conversationDict
        
        //// Update Conversation For Receiver
        let receiverChatUsersRef = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.chatUsers).child(toID.stringValue).child(convDict[ConversationKeys.conversationId] as! String)
        
        if (conversationDict[ConversationKeys.lastMessage] as! String).count == 0 &&  (conversationDict[ConversationKeys.otherConversationId] as! String).count > 0
        {
            var receiverChatUsersRefHanlde = 0 as UInt
            receiverChatUsersRefHanlde = receiverChatUsersRef.observe(.value) { (snapshot) in
                receiverChatUsersRef.removeObserver(withHandle: receiverChatUsersRefHanlde)
                
                if snapshot.exists()
                {
                    var receiverConv = snapshot.value as! [String: NSObject]
                    
                    receiverConv.updateValue(0 as NSObject, forKey: ConversationKeys.deleted)
                    receiverConv.updateValue(0 as NSObject, forKey: ConversationKeys.chatDeletedForUser)
                    receiverConv.updateValue(conversationDict[ConversationKeys.otherConversationId] as! NSObject, forKey: ConversationKeys.otherConversationId)
                    receiverChatUsersRef.setValue(receiverConv)
                    
                    completion()
                }
            }
        }
        else
        {
            convDict.updateValue(0, forKey: ConversationKeys.isRead)
            receiverChatUsersRef.setValue(convDict)
            
            receiverChatUsersRef.setValue(convDict) { (error, ref) in
                
                completion()
            }
        }
    }
}

class MessageHandler
{
    var message: Message? = nil
    var conversationId: String = ""
    
    private var msgRef: DatabaseReference? = nil
    
    init(_ details: [String: NSObject], _ convId: String)
    {
        conversationId = convId
        message = Message(details)
                
        msgRef = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.conversations).child(conversationId).child(message?.messageId ?? "")
                   
                   msgRef?.observe(.childChanged, with: { (messageData) in
                       
                       print(messageData.key, messageData.value ?? "")
                       if messageData.key == ChatKeys.deleteForUser
                       {
                           self.message?.deletedForUsers = messageData.value as? [String : Bool]
                           self.message?.updateDeletedForCurrentUser()
                           
                           if (self.message?.isMsgDeletedForCurrentUser)! == true
                           {
                               self.msgRef?.removeAllObservers()
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: LocalNotificationKeys.messageUpdated), object: self, userInfo: ["deleted": "1"])
                           }
                           else
                           {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: LocalNotificationKeys.messageUpdated), object: self, userInfo: ["deleted": "0"])
                           }
                       }
                       else if messageData.key == ChatKeys.deleted
                       {
                           self.message?.deleted = messageData.value as! NSNumber
                           
                           if self.message?.deleted == 1
                           {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: LocalNotificationKeys.messageUpdated), object: self, userInfo: ["deleted": "0"])
                           }
                       }
                   })
    }
    
    func removeSingleMessageObservers()
    {
        self.msgRef?.removeAllObservers()
    }
}
