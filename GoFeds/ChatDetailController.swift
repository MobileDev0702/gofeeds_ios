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

class ChatDetailController: UIViewController, UITableViewDataSource, UITableViewDelegate {

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
    
    var dbRef: DatabaseReference!
    var roomId: String!
    var receiverId: String!
    var receiverUser: String!
    
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
        loadMessage()
        startObservingKeyboard()
    }
    
    func initFirebase() {
        dbRef = Database.database().reference()
    }
    
    func initData() {
        username.text = receiverUser
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    func setUpTextView() {
      textView.isScrollEnabled = false
      textView.textContainer.heightTracksTextView = true

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
                
                self.dbRef.child("messages").child("chatUsers").child(LoginSession.currentUserId).child(self.roomId).updateChildValues(["lastMessage": msg,
                                                                                                                                   "lastMessageTimeStamp": ServerValue.timestamp(),
                                                                                                                                   "messageId": msgId])
                
                self.dbRef.child("messages").child("chatUsers").child(self.receiverId).child(self.roomId).updateChildValues(["lastMessage": msg,
                                                                                                                             "lastMessageTimeStamp": ServerValue.timestamp(),
                                                                                                                             "messageId": msgId])
                
                if LoginSession.currentUserId == senderId {
                    message = MessageInfo(msg, user: false)
                } else {
                    message = MessageInfo(msg, user: true)
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
                                  "userId": LoginSession.currentUserId])
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
