
//
//  ChatVC.swift
//  GoFeds
//
//  Created by Novos on 20/04/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

var setArray :[String] = ["Kanika","Loveleen Kaur"]
var metArray :[String] = ["Hey","Testing"]

class ChatVC: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var chatTable: UITableView!
    
    //MARK:- Variable
    var users = [User]()
    
    var userChat_fromId : [String] = []
    var userChat_text : [String] = []
    var userChat_timeStamp : [NSNumber] = []
    var userChat_toId : [String] = []
    
    private var conversations: [ConversationHandler] = []
    
    //MARK:- ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetchUsers()
        // observeMessages()
        //observeUserMessages()
        
        NotificationCenter.default.addObserver(self, selector: #selector(conversationsLoaded(_:)), name: NSNotification.Name(rawValue: LocalNotificationKeys.conversationsFetched), object: nil)
        
        addLongPressGstrOnTblVw()
        
//        let instance = FireBaseHandler.shared
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    //MARK:- Function
    
    //    var messages = [MessageModel]()
    //    var chatMessages = [MessageModel]()
    //    var messageDictionary = [String:MessageModel]()
    
    
    func addLongPressGstrOnTblVw()
    {
        let longPressGstr = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPress(_:)))
        longPressGstr.minimumPressDuration = 0.5
        chatTable.addGestureRecognizer(longPressGstr)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer)
    {        
        if gestureRecognizer.state == .ended
        {
            let touchPoint = gestureRecognizer.location(in: chatTable)
            if let indexPath = chatTable.indexPathForRow(at: touchPoint)
            {
                weak var weakSelf: ChatVC? = self
                
                let deleteAction: AlertButtonWithAction = (.delete, NullableCompletion.init({
                    
                    if let conversationToDelete = weakSelf?.conversations[indexPath.row]
                    {
                        var otherUserCashierId: NSNumber?
                        
                        if conversationToDelete.conversation?.creatorId.stringValue == LoginSession.currentUserId
                        {
                            otherUserCashierId = conversationToDelete.conversation?.receiverId
                        }
                        else
                        {
                            otherUserCashierId = conversationToDelete.conversation?.creatorId
                        }
                        
                        FireBaseHandler.shared.deleteConversationForUser(otherUserCashierId?.stringValue ?? "", (conversationToDelete.conversation?.conversationId)!)
                    }
                }))
                
                let cancelAction: AlertButtonWithAction = (.cancel, nil)
                self.showAlertWith(message: .custom("Are you sure to delete conversation?")!, actions: deleteAction, cancelAction)
                
//                CustomAlert.sharedInstance.showTwoOptionsAlertWithHandlerAndTitle("Delete", "Are you sure to delete conversation?", "Delete", "Cancel", vc: weakSelf)
//                {
//                    if let conversationToDelete = weakSelf?.conversations[indexPath.row]
//                    {
//                        var otherUserCashierId: NSNumber?
//
//                        if conversationToDelete.conversation?.creatorId.stringValue == LoginSession.currentUserId
//                        {
//                            otherUserCashierId = conversationToDelete.conversation?.receiverId
//                        }
//                        else
//                        {
//                            otherUserCashierId = conversationToDelete.conversation?.creatorId
//                        }
//
//                        FireBaseHandler.shared.deleteConversationForUser(otherUserCashierId?.stringValue ?? "", (conversationToDelete.conversation?.conversationId)!)
//                    }
//                }
            }
        }
    }
    
    @objc func conversationsLoaded(_ notification: Notification)
    {
        conversations =  notification.object as? [ConversationHandler] ?? []
        chatTable.reloadData()
    }
    
    func fetchData()
    {
        ConversationManager.shared.getAllConversations()
    }
    
    //    func observeUserMessages(){
    //
    //         let currentId = LoginSession.getValueOf(key: SessionKeys.fToken)
    //
    //        let ref = Database.database().reference().child("user-messages").child(currentId)
    //        ref.observe(.childAdded, with: { (snapshot) in
    //
    //            print("user-message")
    //            print(snapshot)
    //
    //            let messageId = snapshot.key
    //            let messagesReference =  Database.database().reference().child("messages").child(messageId)
    //            messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
    //
    //                if let dic = snapshot.value as? [String: AnyObject] {
    //                               print(dic)
    //
    //                               let message = MessageModel()
    //                               message.fromId = dic["fromId"] as? String
    //                               message.text = dic["text"] as? String
    //                               message.timeStamp = dic["timeStamp"] as? NSNumber
    //                               message.toId = dic["toId"] as? String
    //
    //                               //self.messages.append(message)
    //
    //                               if let toId = message.toId {
    //                                self.messageDictionary[toId] = message
    //
    //                                print(self.messages)
    //                                   self.messages = Array(self.messageDictionary.values)
    //                                   self.messages.sort { (message1, message2) -> Bool in
    //                                       return message1.timeStamp!.intValue > message2.timeStamp!.intValue
    //                                    }
    //                               }
    //
    //                               DispatchQueue.main.async {
    //                                   self.chatTable.reloadData()
    //                               }
    //                               //message.setValuesForKeys(dic)
    //                               return
    //                           }
    //
    //
    //
    //            }, withCancel: nil)
    //
    //
    //        }, withCancel: nil)
    //
    //    }
    
    var chat : [String] = []
    
    var chatModel = MessageModel()
    var chat_fromId : [String] = []
    var chat_text : [String] = []
    var chat_timeStamp : [NSNumber] = []
    var chat_toId : [String] = []
    
    //
    //    func observeMessages(){
    //
    //        let db = Database.database().reference()
    //        let ref = db.child("messages")
    //
    //        ref.observe(.childAdded, with: { (snapshot) in
    //
    //            if let dic = snapshot.value as? [String: AnyObject] {
    //                print(dic.count)
    //
    //                let message = MessageModel()
    //                message.fromId = dic["fromId"] as? String
    //                message.text = dic["text"] as? String
    //                message.timeStamp = dic["timeStamp"] as? NSNumber
    //                message.toId = dic["toId"] as? String
    //
    //                self.chat_fromId.append(message.fromId!)
    //                self.chat_text.append(message.text!)
    //                self.chat_timeStamp.append(message.timeStamp!)
    //                self.chat_toId.append(message.toId!)
    //                //self.messages.append(message)
    //
    //                let currentUser_fToken = LoginSession.getValueOf(key: SessionKeys.fToken)
    //
    //                print("toid --> \(message.toId!) ,,,, fromId----> \(message.fromId!)")
    //                print("current user  receiver--> \(currentUser_fToken) ,,,, ")
    //                //print("messages--> \(message.count) ,,,, ")
    //
    //                if message.fromId == currentUser_fToken {
    //                    self.chat.append(message.text!)
    //                }
    //
    //                if message.fromId == currentUser_fToken || message.toId == currentUser_fToken {
    //
    //                    print("Condition matched here>>>")
    //                    if let toId = message.toId {
    //                        print(toId)
    //                        self.messageDictionary[currentUser_fToken] = message
    //                        self.messages = Array(self.messageDictionary.values)
    //                        print(message.fromId)
    //                        print(self.messageDictionary.count)
    //
    //                        self.chatMessages.append(message)
    //                        self.messages.sort { (message1, message2) -> Bool in
    //                            return message1.timeStamp!.intValue > message2.timeStamp!.intValue
    //                         }
    //                    }
    //
    //                    DispatchQueue.main.async {
    //                        self.chatTable.reloadData()
    //                    }
    //
    //                }
    //
    //                //message.setValuesForKeys(dic)
    //               // return
    //            }
    //
    //        }, withCancel: nil)
    //
    //    }
    //
    func sortMessages(){
        
    }
    
    //MARK:- Button Actions
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
//MARK:- TableView Delegate & DataSource
extension ChatVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CommonTableViewCell
        
        let conversation = conversations[indexPath.row].conversation
        cell.chatUsername.text = conversation?.displayName
        
        if(conversation?.deleted == 1)
        {
            if ((conversation?.senderId.stringValue)! == LoginSession.currentUserId)
            {
                cell.userMessage.text = "You deleted this message"
            }
            else
            {
                cell.userMessage.text = "This message is deleted"
            }
        }
        else
        {
            cell.userMessage.text = conversation?.lastMessage
        }
        
        
        
        cell.userDate.text = Date.dateFromTimeInterval((conversation?.lastMessageTimeStamp)!)
        
        
        
        //        if let toId = conversation.toId {
        //            let ref = Database.database().reference().child("users").child(toId)
        //            ref.observeSingleEvent(of: .value, with: { (snapshot) in
        //                print(snapshot)
        //
        //                if let dictionary = snapshot.value as? [String: AnyObject] {
        //                    print("/n/n/n*******")
        //                    print(dictionary)
        //                 cell.chatUsername.text = dictionary["name"] as? String//setArray[indexPath.row]
        //                }
        //            }, withCancel: nil)
        //        }
        //
        //        if let seconds = messageDetails.timeStamp?.doubleValue {
        //
        //            let timeStampDate = NSDate(timeIntervalSince1970: seconds)
        //            let dateFormatter = DateFormatter()
        //            dateFormatter.dateFormat = "hh:mm:ss a "
        //            cell.userDate.text = dateFormatter.string(from: timeStampDate as Date)
        //        }
        //
        
        //        cell.userMessage.text = messageDetails.text//metArray[indexPath.row]
        
        cell.backVW.bottomMaskViewShadow()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
        //        userChat_fromId = []
        //        userChat_text = []
        //        userChat_timeStamp = []
        //        userChat_toId = []
        //
        //        let message = conversations[indexPath.row]
        //        let currentUser_fToken = LoginSession.getValueOf(key: SessionKeys.fToken)
        //
        //        for index in 0..<(chat_toId.count) {
        //
        //            print("chat_toid & ftoken")
        //            print(chat_toId[index],message.toId!)
        //            print("chat_fromid & message-from id ")
        //            print(chat_fromId[index],currentUser_fToken)
        //            print("chat_toid & currentUser_fToken")
        //            print(chat_toId[index],message.fromId)
        //            print("chat_fromid & current ftoken")
        //            print(chat_fromId[index],currentUser_fToken)
        //            //
        //            //                    print(self.messageDictionary)
        //            //                    print(message.text,message.toId,message.fromId)
        //
        //            if (chat_toId[index] == message.toId! && chat_fromId[index] == currentUser_fToken) || (chat_toId[index] == currentUser_fToken && chat_fromId[index] == message.toId!) {
        //
        //                userChat_text.append(chat_text[index])
        //                userChat_fromId.append(chat_fromId[index])
        //                userChat_toId.append(chat_toId[index])
        //                userChat_timeStamp.append(chat_timeStamp[index])
        //
        //            }
        //
        //            print(userChat_text)
        //        }
        
        //    self.openChatController(sender: message.fromId!, receiver: message.toId!, name: "",selectedIndex: indexPath.row)
        
        let conversation = conversations[indexPath.row].conversation
        let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        
        
        if conversation?.creatorId.stringValue == LoginSession.currentUserId
        {
            chatController.recieverUID = conversation?.receiverId.stringValue
            chatController.recieverName = conversation?.receiverUser
        }
        else
        {
            chatController.recieverUID = conversation?.creatorId.stringValue
            chatController.recieverName = conversation?.creatorUser
        }
        
        //  chatController.recieverImgUrl = ""
//         chatController.reciever_ftoken = "" // userData["ftoken"] as? String
        
        chatController.currentConversation = conversations[indexPath.row]
        self.navigationController?.pushViewController(chatController, animated: true)
    }
    
    func openChatController(sender: String, receiver: String,name : String, selectedIndex:Int){
        
        let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        
        let currentUser_fToken = LoginSession.getValueOf(key: SessionKeys.fToken)
        
        var id = receiver
        
        if receiver == currentUser_fToken {
            id = sender
        }
        chatController.userChat_timeStamp = userChat_timeStamp
        chatController.userChat_toId = userChat_toId
        chatController.userChat_fromId = userChat_fromId
        chatController.userChat_text = userChat_text
        //
        chatController.recieverUID = id
        chatController.recieverName = name
        chatController.recieverImgUrl = ""
        chatController.reciever_ftoken = id
        chatController.chatIndex = selectedIndex
        
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    //MARK:- Firebase
    
    func fetchUsers(){
        Database.database().reference().child("users").observeSingleEvent(of: .childAdded) { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject ]{
                let user = User()
                // print(dictionary)
                
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                // user.setValuesForKeys(dictionary)
                //print(user.name, user.email)
                self.users.append(user)
                print(self.users)
                self.chatTable.reloadData()
            }
        }
    }
}
