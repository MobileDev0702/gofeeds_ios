//
//  ConversationHandler.swift
//  CSS POS
//
//  Created by intersoft-admin on 08/10/18.
//  Copyright © 2018 intersoft-kansal. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth

//Contains Info About Single Conversation i.e. Chat With One User
class ConversationHandler
{
    private var conversationRef: DatabaseReference? = nil
    private var singleMsgValueRef: DatabaseReference!
    private var singleMsgAddedRef: DatabaseReference!
    private var singleMessagesArr: [MessageHandler] = []
    private var shouldObserveAddChild: Bool = false
    private var timerToRemoveValueListener: Timer? = nil
    private var databaseHandle: DatabaseHandle? = nil
    
    var conversation: Conversation? = nil
    
    init(_ details: [String: NSObject])
    {
        conversation = Conversation(details)
        
        conversationRef = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.chatUsers).child(LoginSession.currentUserId).child((conversation?.conversationId)!)
        
        conversationRef?.observe(.value, with: { (conversationData) in
            
            if conversationData.exists()
            {                
                self.conversation?.updateConversation(conversationData.value as! [String : NSObject])
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: LocalNotificationKeys.conversationsFetched), object: ConversationManager.shared.conversationsArr)
            }
            
            //            let keys = Constants.Conversation()
            //
            //            print(conversationData.key, conversationData.value ?? "")
            //            if conversationData.key == keys.lastMessage
            //            {
            //                self.conversation?.lastMessage = conversationData.value as! String
            //            }
            //            else if conversationData.key == keys.lastMessageTimeStamp
            //            {
            //                self.conversation?.lastMessageTimeStamp = conversationData.value as! NSNumber
            //            }
            //            else if conversationData.key == keys.messageId
            //            {
            //                self.conversation?.messageId = conversationData.value as! String
            //            }
            //            else if conversationData.key == keys.isRead
            //            {
            //                self.conversation?.isRead = conversationData.value as! NSNumber
            //            }
            
        })
        
        // Add Observer For Message Update
        NotificationCenter.default.addObserver(self, selector: #selector(self.messageUpdated(_:)), name: NSNotification.Name(rawValue: LocalNotificationKeys.messageUpdated), object: nil)
    }
    
    deinit {
        print("Conversation Handler deallocated")
    }
}


extension ConversationHandler
{
    func removeAndCreateNewMsgAddedRef()
    {
        if self.shouldObserveAddChild == false
        {
            singleMsgAddedRef.removeAllObservers()
            singleMsgAddedRef = nil
            self.downloadMessages()
        }
    }
    
    // MARK: Download Single Messages
    func downloadMessages()
    {
        if singleMsgAddedRef == nil
        {
            singleMsgValueRef = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.conversations).child((self.conversation?.conversationId)!)
            
            databaseHandle = singleMsgValueRef.observe(.value) { (snap) in
                
                if snap.exists()
                {
                    print("Single Messages == \(snap)")
                    self.messagesArr(snap.value as! [String : NSObject])
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: LocalNotificationKeys.singleMessagesFetched), object: self.singleMessagesArr)
                }
                
                if self.timerToRemoveValueListener == nil
                {
                    self.timerToRemoveValueListener = Timer.scheduledTimer(timeInterval: TimeInterval(Constants.timeToStopValueListener), target: self, selector: #selector(self.removeValueListnerAndAddOther), userInfo: nil, repeats: false)
                }
                
                self.newMessageAdded()
            }
        }
        else
        {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: LocalNotificationKeys.singleMessagesFetched), object: self.singleMessagesArr)
        }
    }
    
    @objc func removeValueListnerAndAddOther()
    {
        singleMsgValueRef.removeObserver(withHandle: databaseHandle!)
        timerToRemoveValueListener?.invalidate()
        timerToRemoveValueListener = nil
        self.shouldObserveAddChild = true
    }
    
    func newMessageAdded()
    {
        singleMsgAddedRef = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.conversations).child((conversation?.conversationId)!)
        
        singleMsgAddedRef.observe(.childAdded) { (snap) in
            
            print("Single Message Added")
            if snap.exists() && self.shouldObserveAddChild
            {
                print("Single Messages == \(snap)")
                self.addChildMessagesArr(snap.value as! [String: NSObject])
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: LocalNotificationKeys.singleMessagesFetched), object: self.singleMessagesArr)
            }
        }
    }
    
    func getLastMessage() -> Message?
    {
        if singleMessagesArr.count > 0
        {
            for i in stride(from: singleMessagesArr.count, to: 0, by: -1)
            {
                let messageHandler = singleMessagesArr[i-1]
                
                if messageHandler.message?.userId != Auth.auth().currentUser?.uid && messageHandler.message?.isMsgDeletedForCurrentUser == true
                {
                    
                }
                else
                {
                    print("Got Last Message")
                    return messageHandler.message
                }
            }
        }
        
        return nil
    }
    
    @objc func messageUpdated(_ notification: Notification)
    {
        if let messageHandler = notification.object as? MessageHandler
        {
            if let userInfo = notification.userInfo as? [String : String]
            {
                if messageHandler.conversationId == self.conversation?.conversationId
                {
                    if userInfo["deleted"] == "1"
                    {
                        self.removeSingleMsg(messageHandler)
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: LocalNotificationKeys.singleMessagesFetched), object: self.singleMessagesArr)
                }
            }
        }
    }
    
//    func getOtherUserNameFromConversation() -> String
//    {
//        if self.conversation?.creatorId.stringValue == LoginSession.currentUserFToken
//        {
//            return self.conversation?.receiverUser ?? ""
//        }
//        else
//        {
//            return self.conversation?.creatorUser ?? ""
//        }
//    }
}

extension ConversationHandler
{
    func removeConversationHandlerObservers()
    {
        self.conversationRef?.removeAllObservers()
        
        if singleMsgAddedRef != nil
        {
            singleMsgAddedRef.removeAllObservers()
        }
        
        for messageHandler in singleMessagesArr
        {
            messageHandler.removeSingleMessageObservers()
        }
        
        singleMessagesArr.removeAll()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func removeSingleMsg(_ objToRemove: MessageHandler)
    {
        for handlerIndex in 0 ..< singleMessagesArr.count
        {
            let messageHandler = singleMessagesArr[handlerIndex]
            
            if messageHandler.message?.messageId == objToRemove.message?.messageId
            {
                print("Removing Single Message Object == ", messageHandler.message?.messageId ?? 0)
                singleMessagesArr.remove(at: handlerIndex)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: LocalNotificationKeys.singleMessagesFetched), object: self.singleMessagesArr)
                
                break
            }
        }
    }
}

extension ConversationHandler
{
    func getMessage(_ details: [String : NSObject])
    {
        var messageHandlerFound: Bool = false
        let messageIdToFind = details[ChatKeys.id] as? String ?? ""
        
        for messageHandler in singleMessagesArr
        {
            if messageHandler.message?.messageId == messageIdToFind
            {
                messageHandlerFound = true
            }
        }
        
        if messageHandlerFound == false
        {
            let newHandler = MessageHandler.init(details, (conversation?.conversationId)!)
            
            if newHandler.message?.userId != Auth.auth().currentUser?.uid && (newHandler.message?.isMsgDeletedForCurrentUser)!
            {
                // No need to show this Message
            }
            else
            {
                singleMessagesArr.append(newHandler)
            }
        }
    }
    
    func messagesArr(_ info: [String: NSObject])
    {
        for (_, value) in info
        {
            self.getMessage(value as! [String : NSObject])
        }
        
        self.singleMessagesArr.sort{ ($0.message?.timeStamp.intValue)! < ($1.message?.timeStamp.intValue)!}
    }
    
    func addChildMessagesArr(_ info: [String: NSObject])
    {
        self.getMessage(info)
        self.singleMessagesArr.sort{ ($0.message?.timeStamp.intValue)! < ($1.message?.timeStamp.intValue)!}
    }
}
