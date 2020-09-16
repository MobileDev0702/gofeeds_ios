//
//  ChatDetailController.swift
//  GoFeds
//
//  Created by WuSongBai on 2020/9/3.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import FirebaseDatabase
import IQKeyboardManagerSwift
import Alamofire

class ChatDetailController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    private enum Constants {
      static let incomingMessageCell = "incomingMessageCell"
      static let outgoingMessageCell = "outgoingMessageCell"
      static let contentInset: CGFloat = 24
      static let placeholderMessage = "Type something"
    }
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var emptyChatView: UIView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textAreaBackground: UIView!
    @IBOutlet weak var textAreaBottom: NSLayoutConstraint!
    
    let currentUserFToken = LoginSession.getValueOf(key: SessionKeys.fToken)
    
    var dbRef: DatabaseReference!
    var roomId: String!
    var receiverId: String!
    var receiverUser: String!
    var reciever_ftoken: String!
    var deviceId: String!
    var image: String!
    
    var messages: [MessageInfo] = [] {
      didSet {
        emptyChatView.isHidden = !messages.isEmpty
        chatTableView.reloadData()
      }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initFirebase()
        initData()
        setUpTextView()
        setUpTableView()
        startObservingKeyboard()
    }
    
    func initFirebase() {
        dbRef = Database.database().reference()
    }
    
    func initData() {
        username.text = receiverUser
        textView.backgroundColor = UIColor.white
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        let url = MyProfileUrl
        
        Alamofire.request(url,  method: .post, parameters: ["user_id": receiverId!]).responseJSON { response in
            let value = response.result.value as! [String:Any]?
            let BoolValue = value?["success"] as! Bool
            if(BoolValue == true) {
                self.reciever_ftoken = value?["ftoken"] as? String
                self.deviceId = value?["device_id"] as? String
                self.image = value?["image"] as? String
                self.loadMessage()
            }else {
                let okAction: AlertButtonWithAction = (.ok, nil)
                self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
            }
        }
    }
    
    func setUpTextView() {
      textView.isScrollEnabled = true
//      textView.textContainer.heightTracksTextView = true

      textAreaBackground.layer.addShadow(
        color: UIColor(red: 189 / 255, green: 204 / 255, blue: 215 / 255, alpha: 54 / 100),
        offset: CGSize(width: 2, height: -2),
        radius: 4)
    }
    
    private func setUpTableView() {
      chatTableView.rowHeight = UITableView.automaticDimension
      chatTableView.estimatedRowHeight = 80
      chatTableView.tableFooterView = UIView()
      chatTableView.separatorStyle = .none
      chatTableView.contentInset = UIEdgeInsets(top: Constants.contentInset, left: 0, bottom: 0, right: 0)
      chatTableView.allowsSelection = false
    }
    
    private func startObservingKeyboard() {
      let notificationCenter = NotificationCenter.default
      notificationCenter.addObserver(
        forName: UIResponder.keyboardWillShowNotification,
        object: nil,
        queue: nil,
        using: keyboardWillAppear)
      notificationCenter.addObserver(
        forName: UIResponder.keyboardWillHideNotification,
        object: nil,
        queue: nil,
        using: keyboardWillDisappear)
    }
    
    deinit {
      let notificationCenter = NotificationCenter.default
      notificationCenter.removeObserver(
        self,
        name: UIResponder.keyboardWillShowNotification,
        object: nil)
      notificationCenter.removeObserver(
        self,
        name: UIResponder.keyboardWillHideNotification,
        object: nil)
    }
    
    private func keyboardWillAppear(_ notification: Notification) {
      let key = UIResponder.keyboardFrameEndUserInfoKey
      guard let keyboardFrame = notification.userInfo?[key] as? CGRect else {
        return
      }
      
      let safeAreaBottom = view.safeAreaLayoutGuide.layoutFrame.maxY
      let viewHeight = view.bounds.height
      let safeAreaOffset = viewHeight - safeAreaBottom
      
      let lastVisibleCell = chatTableView.indexPathsForVisibleRows?.last
      
      UIView.animate(
        withDuration: 0.3,
        delay: 0,
        options: [.curveEaseInOut],
        animations: {
          self.textAreaBottom.constant = -keyboardFrame.height + safeAreaOffset
          self.view.layoutIfNeeded()
          if let lastVisibleCell = lastVisibleCell {
            self.chatTableView.scrollToRow(
              at: lastVisibleCell, at: .bottom, animated: false)
          }
      })
    }
    
    private func keyboardWillDisappear(_ notification: Notification) {
      UIView.animate(
        withDuration: 0.3,
        delay: 0,
        options: [.curveEaseInOut],
        animations: {
          self.textAreaBottom.constant = 0
          self.view.layoutIfNeeded()
      })
    }
    
    private func scrollToLastCell() {
      let lastRow = chatTableView.numberOfRows(inSection: 0) - 1
      guard lastRow > 0 else {
        return
      }
      
      let lastIndexPath = IndexPath(row: lastRow, section: 0)
      chatTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
    }
    
    func loadMessage() {
        var message: MessageInfo!
        dbRef.child("messages").child("conversations").child(roomId).observe(.childAdded) { (snapshot) in
            if let snapshotValue = snapshot.value as? [String: Any] {
                
                let msg = snapshotValue["message"] as! String
                let senderId = snapshotValue["userId"] as! String
                let msgId = snapshot.key
                
                self.dbRef.child("messages").child("chatUsers").child(LoginSession.getValueOf(key: SessionKeys.showId)).child(self.roomId).updateChildValues(["lastMessage": msg,
                                                                                                                                   "lastMessageTimeStamp": ServerValue.timestamp(),
                                                                                                                                   "messageId": msgId,
                                                                                                                                   "image": "http://stackrage.com/gofeeds/images/\(self.image!)"])
                
                self.dbRef.child("messages").child("chatUsers").child(self.receiverId).child(self.roomId).updateChildValues(["lastMessage": msg,
                                                                                                                             "lastMessageTimeStamp": ServerValue.timestamp(),
                                                                                                                             "messageId": msgId,
                                                                                                                             "image": "http://stackrage.com/gofeeds/images/\(LoginSession.getValueOf(key: SessionKeys.image))"])
                
                if LoginSession.getValueOf(key: SessionKeys.showId) == senderId {
                    message = MessageInfo(msg, avatar: LoginSession.getValueOf(key: SessionKeys.image), user: false)
                } else {
                    message = MessageInfo(msg, avatar: self.image, user: true)
                }
                self.messages.append(message)
                self.scrollToLastCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cellIdentifier = message.isUser ?
          Constants.incomingMessageCell :
          Constants.outgoingMessageCell
        
        guard let cell = tableView.dequeueReusableCell(
          withIdentifier: cellIdentifier, for: indexPath)
          as? MessageCell & UITableViewCell else {
            return UITableViewCell()
        }
        
        cell.message = message
        cell.showsAvatar = true
        
//        if indexPath.row < messages.count - 1 {
//          let nextMessage = messages[indexPath.row + 1]
//          cell.showsAvatar = true //message.isIncoming != nextMessage.isIncoming
//        } else {
//          cell.showsAvatar = true
//        }
        
        return cell
    }
    
    @IBAction func onClickBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSendBtn(_ sender: UIButton) {
        if textView.text.count > 0 {
            let messageRef = dbRef.child("messages").child("conversations").child(roomId).childByAutoId()
            setConversationDB(msgRef: messageRef)
            
            let timeStamp : NSNumber =  NSNumber(value: Int(NSDate().timeIntervalSince1970))
            let seconds = timeStamp.doubleValue
            let timeStampDate = NSDate(timeIntervalSince1970: seconds)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss a "
            let dateString = dateFormatter.string(from: timeStampDate as Date)
            let msg = self.textView.text
            DispatchQueue.main.async {
                self.sendPush(txt: msg!, senderId: self.currentUserFToken,msgDate: dateString)
            }
            textView.text = ""
        } else {
            let okAction: AlertButtonWithAction = (.ok, nil)
            self.showAlertWith(message: .custom("Write your message!")!, actions: okAction)
        }
    }
    
    func setConversationDB(msgRef: DatabaseReference) {
        msgRef.updateChildValues(["deleteForUser": ["myId": false],
                                  "deleted": 0,
                                  "id": msgRef.key!,
                                  "message": textView.text!,
                                  "timestamp": ServerValue.timestamp(),
                                  "userId": LoginSession.getValueOf(key: SessionKeys.showId)])
    }
    
    func sendPush(txt:String,senderId:String,msgDate:String)
    {
        let url = UpdateBadge
        
        Alamofire.request(url,  method: .post, parameters: ["id": receiverId!, "reset": false]).responseJSON { response in
            let value = response.result.value as! [String:Any]?
            let BoolValue = value?["success"] as! Bool
            if(BoolValue == true) {
                let badgeCount = value?["badgeCount"] as! Int
                var request = URLRequest(url: URL(string: "https://fcm.googleapis.com/fcm/send")!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("key=AAAA_QjVv44:APA91bEpd8HIWReOMvyPT_vtT-hPB4P6nHJqjNmnAKGL-ZTDEH0L9ptEUQ8bVQzllbAhQiiaHQ3_EFdoCqO1xbdxP1v5TNXG2_qtvgMwwZ8n-vAHPJWIv__PI7PPUO8AjNoQremscAma", forHTTPHeaderField: "Authorization")
                var json: [String: Any]
                if self.deviceId! == "iPhone" {
                    json = [
                    "to" : self.reciever_ftoken! as String,
                    "priority" : "high","message":txt,"mSender_id":senderId,"sound":"enabled",
                    "notification" : [
                        "body":txt,"badge":badgeCount, "mSender_id":senderId,"sound": "default", "title":"You Have a New Message"
                    ],"data" : [
                        "mSender_id":senderId,"mReciver_id":LoginSession.getValueOf(key: SessionKeys.showId), "badge":badgeCount, "roomId":self.roomId!, "receiverUser":LoginSession.getValueOf(key: SessionKeys.userName), "body":txt, "title":"You Have a New Message"
                    ]
                    ] as [String : Any]
                } else {
                    json = [
                    "to" : self.reciever_ftoken! as String,
                    "priority" : "high","message":txt,"mSender_id":senderId,"sound":"enabled",
                    "data" : [
                        "mSender_id":senderId,"mReciver_id":LoginSession.getValueOf(key: SessionKeys.showId), "badge":badgeCount, "roomId":self.roomId!, "receiverUser":LoginSession.getValueOf(key: SessionKeys.userName), "body":txt, "title":"You Have a New Message"
                    ]
                    ] as [String : Any]
                }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    request.httpBody = jsonData
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {
                            print("Error=\(String(describing: error?.localizedDescription))")
                            return
                        }
                        
                        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                            // check for http errors
                            print("Status Code should be 200, but is \(httpStatus.statusCode)")
                            print("Response = \(String(describing: response))")
                        }
                        
                        let responseString = String(data: data, encoding: .utf8)
                        print("responseString = \(String(describing: responseString))")
                    }
                    task.resume()
                }
                catch {
                    print(error)
                }
            }else {
                let okAction: AlertButtonWithAction = (.ok, nil)
                self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
