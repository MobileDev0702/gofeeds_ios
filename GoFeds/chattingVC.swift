//
//  chattingVC.swift
//  GoFeds
//
//  Created by Novos on 20/04/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase
import FirebaseFirestore
import SDWebImage

class chattingVC: MessagesViewController , MessagesLayoutDelegate, MessagesDisplayDelegate , InputBarAccessoryViewDelegate, MessagesDataSource {
    
    // var currentUser: User = Auth.auth().currentUser!
    private var docReference: DocumentReference?
    var messages: [Message] = []
    
    var user2Name: String?
    var user2ImgUrl: String?
    var user2UID: String?
    
    private var heightOfHeader: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         heightOfHeader = 75
         ConversationScreenHeader(superView: view, height: heightOfHeader).setup()
         AdaptedMessagesCollectionView(messagesCollectionView: messagesCollectionView, superView: view, topIndent: heightOfHeader).adapt()
         */
        
        self.title = user2Name ?? "Chat"
        navigationItem.largeTitleDisplayMode = .never
        
        //  maintainPositionOnKeyboardFrameChanged = true
        
        self.navigationController?.navigationBar.isHidden = false
        
        self.tabBarController?.tabBar.isHidden = true
        messageInputBar.inputTextView.tintColor = .blue
        messageInputBar.sendButton.setTitleColor(.blue, for: .normal)
        messageInputBar.delegate = self
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
           // self.loadChat()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func onClickBackAcn() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //     func loadChat() {
    //         //Fetch all the chats which has current user in it
    //
    //        // let db = Firestore.firestore().collection("Chats").whereField("users", arrayContains: Auth.auth().currentUser?.uid ?? "Not Found User 1")
    //
    //        let db = Firestore.firestore().collection("Chats").whereField("users", arrayContains: CurrentUserInfo.showID! )
    //
    //         db.getDocuments { (chatQuerySnap, error) in
    //             if let error = error {
    //                 print("Error: \(error)")
    //                 return
    //             } else {
    //                 //Count the no. of documents returned
    //                 guard let queryCount = chatQuerySnap?.documents.count else {
    //                     return
    //                 }
    //                 if queryCount == 0 {
    //                     //If documents count is zero that means there is no chat available and we need to create a new instance
    //                     self.createNewChat()
    //                 }
    //                 else if queryCount >= 1 {
    //                     //Chat(s) found for currentUser
    //                     for doc in chatQuerySnap!.documents {
    //                         let chat = Chat(dictionary: doc.data())
    //                         //Get the chat which has user2 id
    //                         if (chat?.users.contains(self.user2UID!))! {
    //                             self.docReference = doc.reference
    //                             //fetch it's thread collection
    //                             doc.reference.collection("thread")
    //                                 .order(by: "created", descending: false)
    //                                 .addSnapshotListener(includeMetadataChanges: true, listener: { (threadQuery, error) in
    //                                     if let error = error {
    //                                         print("Error: \(error)")
    //                                         return
    //                                     } else {
    //                                         self.messages.removeAll()
    //                                         for message in threadQuery!.documents {
    //                                             let msg = Message(dictionary: message.data())
    //                                             self.messages.append(msg!)
    //                                             print("Data: \(msg?.content ?? "No message found")")
    //                                         }
    //                                         self.messagesCollectionView.reloadData()
    //                                         self.messagesCollectionView.scrollToBottom(animated: true)
    //                                     }
    //                                 })
    //                             return
    //                         } //end of if
    //                     } //end of for
    //                     self.createNewChat()
    //                 } else {
    //                     print("Let's hope this error never prints!")
    //                 }}}}
    //
    //     func createNewChat() {
    //                 let users = [CurrentUserInfo.showID!, self.user2UID]
    //                     let data: [String: Any] = [
    //                         "users":users
    //                 ]
    //                 let db = Firestore.firestore().collection("Chats")
    //                 db.addDocument(data: data) { (error) in
    //                     if let error = error {
    //                         print("Unable to create chat! \(error)")
    //                         return
    //                     } else {
    //                         self.loadChat()
    //                     }
    //                 }
    //         }
    //
    //Handle msg
    
    func handleSend(inputText: String){
        let db = Database.database().reference()
        let ref = db.child("messages")
        //let userName = CurrentUserInfo.firstname + " " + CurrentUserInfo.lastname
        let values = ["text":inputText,"name":user2Name!]
        
        setArray.append(user2Name!)
        metArray.append(inputText)
        
        ref.updateChildValues(values)
    }
    
    private func insertNewMessage(_ message: Message) {
        //add the message to the messages array and reload it
        messages.append(message)
        messagesCollectionView.reloadData()
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
    }
    private func save(_ message: Message) {
//        //Preparing the data as per our firestore collection
//        let data: [String: Any] = [
//            "content": message.content,
//            "created": message.created,
//            "id": message.id,
//            "senderID": message.senderID,
//            "senderName": message.senderName
//        ]
//        //Writing it to the thread using the saved document reference we saved in load chat function
//        docReference?.collection("thread").addDocument(data: data, completion: { (error) in
//            if let error = error {
//                print("Error Sending message: \(error)")
//                return
//            }
//            self.messagesCollectionView.scrollToBottom()
//        })
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        //When use press send button this method is called.
        
//        let message = Message(id: UUID().uuidString, content: text, created: Timestamp(), senderID: CurrentUserInfo.showID!, senderName: CurrentUserInfo.firstname!)
//        
//        //calling function to insert and save message
//        insertNewMessage(message)
//        save(message)
//        handleSend(inputText: text)
        //clearing input field
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
    //This method return the current sender ID and name
    func currentSender() -> SenderType {
        
        return Sender(senderId: CurrentUserInfo.showID!, displayName: CurrentUserInfo.firstname! )
        
        //  return Sender(id: Auth.auth().currentUser!.uid, displayName: Auth.auth().currentUser?.displayName ?? "Name not found")
        
    }
    
    //This return the MessageType which we have defined to be text in Messages.swift
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    //Return the total number of messages
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        if messages.count == 0 {
            print("There are no messages")
            return 0
        } else {
            return messages.count
        }
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        return CGSize(width: 0, height: 8)
    }
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath,
                           with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 0
    }
    
    
    //Background colors of the bubbles
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        return isFromCurrentSender(message: message) ? .blue: .lightGray
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> Bool {
        
        return false
    }
    
    //THis function shows the avatar
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        //If it's current user show current user photo.
        if message.sender.senderId == CurrentUserInfo.showID! {
            SDWebImageManager.shared.loadImage(with:URL(string: "user2ImgUrl"), options: .highPriority, progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
                avatarView.image = image
            }
        } else {
            SDWebImageManager.shared.loadImage(with: URL(string: user2ImgUrl!), options: .highPriority, progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
                avatarView.image = image
            }
        }
    }
    
    //Styling the bubble to have a tail
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    
    
    
}


/*
 struct ConversationScreenHeader {
 
 private let superView: UIView
 private let height: CGFloat
 
 init(superView: UIView, height: CGFloat) {
 
 self.superView = superView
 self.height = height
 }
 
 func setup() {
 
 let header = UIView()
 header.backgroundColor = UIColor.lightGray.withAlphaComponent(0.25)
 header.translatesAutoresizingMaskIntoConstraints = false
 superView.addSubview(header)
 
 let topConstraint = NSLayoutConstraint(item: header, attribute: .top, relatedBy: .equal, toItem: superView, attribute: .top, multiplier: 1, constant: 0)
 let leadingConstraint = NSLayoutConstraint(item: header, attribute: .leading, relatedBy: .equal, toItem: superView, attribute: .leading, multiplier: 1, constant: 0)
 let trailingConstraint = NSLayoutConstraint(item: header, attribute: .trailing, relatedBy: .equal, toItem: superView, attribute: .trailing, multiplier: 1, constant: 0)
 let heightConstraint = NSLayoutConstraint(item: header, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
 
 NSLayoutConstraint.activate([topConstraint, leadingConstraint, trailingConstraint, heightConstraint])
 }
 }
 
 struct AdaptedMessagesCollectionView {
 
 private let messagesCollectionView: MessagesCollectionView
 private let superView: UIView
 private let topIndent: CGFloat
 
 init(messagesCollectionView: MessagesCollectionView, superView: UIView, topIndent: CGFloat) {
 
 self.messagesCollectionView = messagesCollectionView
 self.superView = superView
 self.topIndent = topIndent
 }
 
 func adapt() {
 
 messagesCollectionView.removeFromSuperview()
 superView.addSubview(messagesCollectionView)
 
 messagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
 let topConstraint = NSLayoutConstraint(item: messagesCollectionView, attribute: .top, relatedBy: .equal, toItem: superView, attribute: .top, multiplier: 1, constant: topIndent)
 let leadingConstraint = NSLayoutConstraint(item: messagesCollectionView, attribute: .leading, relatedBy: .equal, toItem: superView, attribute: .leading, multiplier: 1, constant: 0)
 let trailingConstraint = NSLayoutConstraint(item: messagesCollectionView, attribute: .trailing, relatedBy: .equal, toItem: superView, attribute: .trailing, multiplier: 1, constant: 0)
 let bottomConstraint = NSLayoutConstraint(item: messagesCollectionView, attribute: .bottom, relatedBy: .equal, toItem: superView, attribute: .bottom, multiplier: 1, constant: 0)
 
 NSLayoutConstraint.activate([topConstraint, leadingConstraint, trailingConstraint, bottomConstraint])
 }
 }
 */


