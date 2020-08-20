//
//  MyProfileVC.swift
//  GoFeds
//
//  Created by Novos on 17/04/20.
//  Copyright © 2020 Novos. All rights reserved.
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
    
    //MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPortTextfield.isUserInteractionEnabled = false
        desiredPortTectfield.isUserInteractionEnabled = false
        print(userData)
        //print(CurrentUserInfo.showID!)
        self.setProfileInfo()
       // observeMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
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
        
        lblUserName.text = name
        rankTextfield.text = rank
        agencyTextfield.text = agency
        officeTextfield.text = office
        currentPortTextfield.text = current_port
        desiredPortTectfield.text = desired_port
        }
    }
    
    //MARK:- Button Actions
    
    @IBAction func startChatBtn(_ sender: Any) {
       
        // Get AllConversations First
        ConversationManager.shared.getAllConversations()
        
        self.openChatController()
    /*
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "chattingVC") as? chattingVC
        let id = Int(userData["user_id"] as! String)!
        vc?.user2UID =  String("\(id)")
        vc?.user2Name = (userData["name"] as! String)
        vc?.user2ImgUrl = ""
        
        self.navigationController?.pushViewController(vc!, animated: true)
 */
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
                
                self.navigationController?.pushViewController(chatController, animated: true)
            }
        }
        else
        {
            self.navigationController?.pushViewController(chatController, animated: true)
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
