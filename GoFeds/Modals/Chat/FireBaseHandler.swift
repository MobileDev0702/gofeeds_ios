//
//  FireBaseHandler.swift
//  POS-Native
//
//  Created by intersoft-kansal on 02/12/17.
//  Copyright © 2017 intersoft-kansal. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseDatabase
import Firebase

//MARK: Alert Functions
typealias Categories = (_ categories: [DataSnapshot]) -> ()

class FireBaseHandler
{
    static var shared = FireBaseHandler()

    // Chat
    var conversationRef: DatabaseReference!
    var chatUsersRef: DatabaseReference!
        
    private init()
    {
        if Database.database().isPersistenceEnabled == false
        {
            Database.database().isPersistenceEnabled = true
        }
    }
    
    func resetFireBaseHandler()
    {
        if conversationRef != nil
        {
            conversationRef.removeAllObservers()
        }
        
        if chatUsersRef != nil
        {
            chatUsersRef.removeAllObservers()
        }
        
        NotificationCenter.default.removeObserver(self)
        //FireBaseHandler.shared = FireBaseHandler()
    }
    
    deinit
    {
        print("FireBase Handler Deallocated")
    }
}


extension FireBaseHandler
{
    // MARK: Send Message in Group
    
    // MARK: Delete Whole Conversation
    
    func deleteConversationForUser(_ otherCashierId: String, _ convId: String)
    {
        let cashierId = LoginSession.currentUserId
        
        if chatUsersRef != nil
        {
            chatUsersRef.removeAllObservers()
        }
        
        chatUsersRef = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.chatUsers)
        
        var chatUsersRefHanlde = 0 as UInt
        chatUsersRefHanlde = chatUsersRef.observe(.value) { (snapshot) in
            self.chatUsersRef.removeObserver(withHandle: chatUsersRefHanlde)
            
            if snapshot.exists()
            {
                let conversation = snapshot.value as! [String: NSObject]
                
                self.chatUsersRef.child(cashierId).child(convId).removeValue { (error, ref) in
                    
                    print(error ?? "")
                                        
                    if conversation[ConversationKeys.conversationId] != conversation[ConversationKeys.otherConversationId] && (conversation[ConversationKeys.otherConversationId] as! String).count > 0
                    {
                        let otherConvId = conversation[ConversationKeys.otherConversationId]
                        
                        self.updateConversationOfOtherUser(otherConvId as! String, otherCashierId)
                    }
                    else
                    {
                        self.updateConversationOfOtherUser(convId, otherCashierId)
                    }
                }
            }
        }
    }
    
    func updateConversationOfOtherUser(_ convId: String, _ otherCashierId: String)
    {
        chatUsersRef = chatUsersRef.child(otherCashierId).child(convId)
        
        var chatUsersRefHanlde = 0 as UInt
        chatUsersRefHanlde = chatUsersRef.observe(.value) { (snapshot) in
            self.chatUsersRef.removeObserver(withHandle: chatUsersRefHanlde)
            
            if var conversation = snapshot.value as? [String: NSObject]
            {
                let cashierId = LoginSession.currentUserId
                
                conversation.updateValue(cashierId as NSObject, forKey: ConversationKeys.chatDeletedForUser)
                
                self.chatUsersRef.setValue(conversation)
                
                if conversation[ConversationKeys.conversationId] != conversation[ConversationKeys.otherConversationId] && (conversation[ConversationKeys.otherConversationId] as! String).count > 0
                {
                    self.deleteChatWithId(conversation[ConversationKeys.otherConversationId] as! String)
                    conversation.updateValue("" as NSObject, forKey: ConversationKeys.otherConversationId)
                }
            }
        }
    }
    
    func deleteChatWithId(_ convId: String)
    {
        let deleteConvRef = Database.database().reference().child(FirebaseKeys.messages).child(FirebaseKeys.conversations).child(convId)
        
        deleteConvRef.removeValue { (error, ref) in
            
            print("Error >>>>", error ?? "")
        }
    }
}
