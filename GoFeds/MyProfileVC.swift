//
//  MyProfileVC.swift
//  GoFeds
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase

class MyProfileVC: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var chooseProfilePicBtn: UIButton!
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var profilePicImgVW: UIImageView!
    @IBOutlet weak var rankTextfield: UITextField!
    @IBOutlet weak var agencyTextfield: UITextField!
    @IBOutlet weak var officeTextfield: UITextField!
    @IBOutlet weak var currentPortTextfield: UITextField!
    @IBOutlet weak var desiredPortTectfield: UITextField!
    @IBOutlet weak var startChatBtn: UIButton!
    
    //MARK:- Variables
    var userData = NSDictionary()
    
    var userChat_fromId : [String] = []
    var userChat_text : [String] = []
    var userChat_timeStamp : [NSNumber] = []
    var userChat_toId : [String] = []
    
    var chat_fromId : [String] = []
    var chat_text : [String] = []
    var chat_timeStamp : [NSNumber] = []
    var chat_toId : [String] = []
    
    var roomId: String!
    var myId: Int!
    var userId: Int!
    var dbRef: DatabaseReference!
    
    //MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPortTextfield.isUserInteractionEnabled = false
        desiredPortTectfield.isUserInteractionEnabled = false
        print(userData)
        //print(CurrentUserInfo.showID!)
        self.setProfileInfo()
       // observeMessages()
        initFirebase()
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func initFirebase() {
        dbRef = Database.database().reference()
    }
    
    func initData() {
        profilePicImgVW.layer.cornerRadius = profilePicImgVW.frame.size.height / 2
        profilePicImgVW.layer.borderWidth = 1
        profilePicImgVW.layer.borderColor = UIColor.white.cgColor
        profilePicImgVW.clipsToBounds = true
        profilePicImgVW.contentMode = .scaleAspectFit
        
        myId = Int(LoginSession.getValueOf(key: SessionKeys.showId))!
        userId = Int(userData["user_id"] as! String)!
    }
    
    func setProfileInfo(){
        
        if userData["username"] != nil {
        
//        let name = UserDefaults.standard.value(forKey: "userName") as! String
//        let rank = UserDefaults.standard.value(forKey: "rank") as! String
//        let agency = UserDefaults.standard.value(forKey: "agency") as! String
       // let office = UserDefaults.standard.value(forKey: "office") as! String
//        let current_port = UserDefaults.standard.value(forKey: "showName") as! String
//        let desired_port = UserDefaults.standard.value(forKey: "desiredPort") as! String
        let name = userData["username"] as! String
        let rank = userData["rank"] as! String
        let agency = userData["agency"] as! String
        let office = userData["office"] as! String
        let current_port = userData["current_port"] as! String
        let desired_port = userData["desire_port"] as! String
            let image: String!
            if (userData["image"] as! String).isEmpty {
                image = "user1.png"
            } else {
                image = userData["image"] as? String
            }
        
        lblUserName.text = name
        rankTextfield.text = rank
        agencyTextfield.text = agency
        officeTextfield.text = office
        currentPortTextfield.text = current_port
        desiredPortTectfield.text = desired_port
            profilePicImgVW.sd_setImage(with: URL(string: "http://stackrage.com/gofeeds/images/\(image!)"), completed: nil)
        }
    }
    
    //MARK:- Button Actions
    
    @IBAction func startChatBtn(_ sender: Any) {
       
        // Get AllConversations First
//        ConversationManager.shared.getAllConversations()
        
        dbRef.child("messages").child("chatUsers").child("\(myId!)").observeSingleEvent(of: .value) { (snapshot) in
            var roomCnt = 0
            if snapshot.hasChildren() {
                if let snapshotValue = snapshot.value as? [String: Any] {
                    for child in snapshotValue {
                        if let childValue = child.value as? [String: Any] {
                            let receiverId = childValue["receiverId"] as! Int
                            let senderId = childValue["senderId"] as! Int
                            if (senderId == self.userId && receiverId == self.myId) || (senderId == self.myId && receiverId == self.userId) {
                                self.roomId = childValue["conversationId"] as? String
                            } else {
                                roomCnt += 1
                            }
                        }
                    }
                    if snapshot.childrenCount == roomCnt {
                        let roomRef = self.dbRef.child("messages").child("chatUsers").child("\(self.myId!)").childByAutoId()
                        self.roomId = roomRef.key
                        self.initChatUserDB(ref: roomRef)
                    }
                }
            } else {
                let roomRef = self.dbRef.child("messages").child("chatUsers").child("\(self.myId!)").childByAutoId()
                self.roomId = roomRef.key
                self.initChatUserDB(ref: roomRef)
            }
            self.performSegue(withIdentifier: "ProfileToChatDetailVC", sender: nil)
        }
//        self.openChatController()
    /*
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "chattingVC") as? chattingVC
        let id = Int(userData["user_id"] as! String)!
        vc?.user2UID =  String("\(id)")
        vc?.user2Name = (userData["name"] as! String)
        vc?.user2ImgUrl = ""
        
        self.navigationController?.pushViewController(vc!, animated: true)
 */
    }
    
    func initChatUserDB(ref: DatabaseReference) {
        let image: String!
        if (LoginSession.getValueOf(key: SessionKeys.image)).isEmpty {
            image = "user.png"
        } else {
            image = LoginSession.getValueOf(key: SessionKeys.image)
        }
        ref.updateChildValues(["chatDeletedForUser": 0,
                               "conversationId": ref.key!,
                               "creatorId": myId!,
                               "creatorUser": LoginSession.getValueOf(key: SessionKeys.userName),
                               "deleted": 0,
                               "isRead": 1,
                               "lastMessage": "",
                               "lastMessageTimeStamp": ServerValue.timestamp(),
                               "messageId": "",
                               "otherConversationId": "",
                               "receiverId": userId!,
                               "receiverUser": userData["username"] as! String,
                               "senderId": myId!,
                               "timestamp": ServerValue.timestamp(),
                               "image": "http://stackrage.com/gofeeds/images/\(image!)"])
        
        let myImage: String!
        if (userData["image"] as! String).isEmpty {
            myImage = "user.png"
        } else {
            myImage = LoginSession.getValueOf(key: SessionKeys.image)
        }
        dbRef.child("messages").child("chatUsers")
            .child("\(userId!)")
            .child(ref.key!)
            .updateChildValues(["chatDeletedForUser": 0,
                                "conversationId": ref.key!,
                                "creatorId": myId!,
                                "creatorUser": LoginSession.getValueOf(key: SessionKeys.userName),
                                "deleted": 0,
                                "isRead": 1,
                                "lastMessage": "",
                                "lastMessageTimeStamp": ServerValue.timestamp(),
                                "messageId": "",
                                "otherConversationId": "",
                                "receiverId": myId!,
                                "receiverUser": LoginSession.getValueOf(key: SessionKeys.userName),
                                "senderId": userId!,
                                "timestamp": ServerValue.timestamp(),
                                "image": "http://stackrage.com/gofeeds/images/\(myImage!)"])
    }
    
    func openChatController(){
//        let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
//
//        let id = userData["user_id"] as! String
//        chatController.recieverUID = id
//        chatController.recieverName = userData["username"] as? String
//        chatController.recieverImgUrl = ""
//        chatController.reciever_ftoken = userData["ftoken"] as? String
//
//
//        navigationController?.pushViewController(chatController, animated: true)
        
        let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        
        let id = userData["user_id"] as! String
        chatController.recieverUID = id
        chatController.recieverName = userData["username"] as? String
        chatController.recieverImgUrl = ""
        chatController.reciever_ftoken = userData["ftoken"] as? String
        
        chatController.currentConversation = ConversationManager.shared.getConversationForUser(id.nsnumValue() )
        
        if chatController.currentConversation == nil
        {
            ConversationManager.shared.checkAndCreateNewConversation(id.nsnumValue(), chatController.recieverName ?? "") { () in
                
                chatController.currentConversation = ConversationManager.shared.getConversationForUser(id.nsnumValue())
                self.roomId = chatController.currentConversation!.conversation!.conversationId
//                self.navigationController?.pushViewController(chatController, animated: true)
                self.performSegue(withIdentifier: "ProfileToChatDetailVC", sender: nil)
            }
        }
        else
        {
            roomId = chatController.currentConversation!.conversation!.conversationId
            performSegue(withIdentifier: "ProfileToChatDetailVC", sender: nil)
//            self.navigationController?.pushViewController(chatController, animated: true)
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileToChatDetailVC" {
            if let destinationVC = segue.destination as? ChatDetailController {
                destinationVC.roomId = roomId
                destinationVC.receiverId = userData["user_id"] as? String
                destinationVC.receiverUser = userData["username"] as? String
            }
        }
    }
    
    let message = MessageModel()
    
//    func observeMessages(){
//
//          let db = Database.database().reference()
//          let ref = db.child("messages")
//
//          ref.observe(.childAdded, with: { (snapshot) in
//
//              if let dic = snapshot.value as? [String: AnyObject] {
//                  print(dic)
//
//               // DispatchQueue.main.async {
//                 // let message = MessageModel()
//                    self.message.fromId = dic["fromId"] as? String
//                    self.message.text = dic["text"] as? String
//                    self.message.timeStamp = dic["timeStamp"] as? NSNumber
//                    self.message.toId = dic["toId"] as? String
//
//                    self.chat_fromId.append(self.message.fromId!)
//                    self.chat_text.append(self.message.text!)
//                    self.chat_timeStamp.append(self.message.timeStamp!)
//                    self.chat_toId.append(self.message.toId!)
//
//               // }
//                  //self.messages.append(message)
//
//
//                  }
//
//              }, withCancel: nil)
//
//        print(self.chat_text)
//
//    }
          
//    func openChatController(sender: String, receiver: String,name : String){
//
//              let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
//
//              var id = receiver
//
//              if receiver == sender {
//                  id = sender
//              }
//
//
//        // update user array
//
//                 userChat_fromId = []
//                 userChat_text = []
//                 userChat_timeStamp = []
//                 userChat_toId = []
//
//               // let message = messages[0]
//                //let currentUser_fToken = UserDefaults.standard.value(forKey: "ftoken") as! String
//
//                for index in 0..<(chat_toId.count) {
//
////                            print("chat_toid & ftoken")
////                            print(chat_toId[index],message.toId!)
////                            print("chat_fromid & message-from id ")
////                            print(chat_fromId[index],currentUser_fToken)
////                            print("chat_toid & currentUser_fToken")
////                            print(chat_toId[index],message.fromId)
////                            print("chat_fromid & current ftoken")
////                            print(chat_fromId[index],currentUser_fToken)
//        //
//        //                    print(self.messageDictionary)
//        //                    print(message.text,message.toId,message.fromId)
//
//                    if (chat_toId[index] == id && chat_fromId[index] == LoginSession.currentUserFToken) || (chat_toId[index] == LoginSession.currentUserFToken && chat_fromId[index] == id) {
//
//                        userChat_text.append(chat_text[index])
//                        userChat_fromId.append(chat_fromId[index])
//                        userChat_toId.append(chat_toId[index])
//                        userChat_timeStamp.append(chat_timeStamp[index])
//
//                    }
//
//        }
//                    print(userChat_text)
//
//
//              chatController.userChat_timeStamp = userChat_timeStamp
//              chatController.userChat_toId = userChat_toId
//              chatController.userChat_fromId = userChat_fromId
//              chatController.userChat_text = userChat_text
//      //
//              chatController.recieverUID = id
//              chatController.recieverName = name
//              chatController.recieverImgUrl = ""
//              chatController.reciever_ftoken = id
//              navigationController?.isNavigationBarHidden = false
//              navigationController?.pushViewController(chatController, animated: true)
//          }
      
    
}
