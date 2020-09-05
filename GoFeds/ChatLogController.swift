//
//  ChatLogController.swift
//  GoFeds
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import Alamofire

class ChatLogController: UICollectionViewController , UITextFieldDelegate , UICollectionViewDelegateFlowLayout{
    
    let cellId = "cellId"
    var recieverName: String?
    var recieverImgUrl: String?
    var recieverUID: String?
    var reciever_ftoken: String?
    
    var chatIndex = 0
    var chat : [String] = []
    var count = 0
    var chatModel = MessageModel()
    var chat_fromId : [String] = []
    var chat_text : [String] = []
    var chat_timeStamp : [NSNumber] = []
    var chat_toId : [String] = []
    
    var userChat_fromId : [String] = []
    var userChat_text : [String] = []
    var userChat_timeStamp : [NSNumber] = []
    var userChat_toId : [String] = []
    
    var messages = [MessageHandler]()
    var chatMessages = [MessageModel]()
    var messageDictionary = [String:MessageModel]()
    
    // var allMessagesArray = NSMutableArray()
    
    //Public
    var currentConversation: ConversationHandler?
    
    lazy var inputTextField : UITextField = {
        let textField = UITextField()
        textField.textColor = UIColor.black
        textField.placeholder = "Enter Text Here..."
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let currentUserFToken = LoginSession.getValueOf(key: SessionKeys.fToken)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        count = userChat_toId.count
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = false
        
        navigationItem.title = recieverName!
        collectionView.backgroundColor = .white
        //setupInputComponents()
        
        self.setupKeyboardObserver()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 66, right: 0)
        //collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView.register(chatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        print(userChat_text)
        
        print("\(collectionView.frame.height) \(collectionView.frame.origin.x) \(collectionView.frame.origin.y)")
        //print(reciever_ftoken!)
        
        let url = MyProfileUrl
        
        Alamofire.request(url,  method: .post, parameters: ["user_id": recieverUID!]).responseJSON { response in
            let value = response.result.value as! [String:Any]?
            let BoolValue = value?["success"] as! Bool
            if(BoolValue == true) {
                self.reciever_ftoken = value?["ftoken"] as? String
            }else {
                let okAction: AlertButtonWithAction = (.ok, nil)
                self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
            }
        }
        
        // self.updateRealtimeChat()
        
        // Switch to background thread to perform heavy task.
        DispatchQueue.global(qos: .default).async {
            // Perform heavy task here.
            
            // Switch back to main thread to perform UI-related task.
            DispatchQueue.main.async {
                // Update UI.
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(singleMessagesLoaded(_:)), name: NSNotification.Name(rawValue: LocalNotificationKeys.singleMessagesFetched), object: nil)
        
        self.addLongPressGstrOnTblVw()
    }
    
    @objc func dismissKeyboard() {
        
//        self.view.endEditing(true)
        self.inputTextField.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.fetchData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:- Keyboard handlers
    func setupKeyboardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addLongPressGstrOnTblVw()
    {
        let longPressGstr = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPress(_:)))
        // longPressGstr.minimumPressDuration = 0.5
        self.collectionView.addGestureRecognizer(longPressGstr)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer)
    {
        if gestureRecognizer.state == .ended
        {
            let touchPoint = gestureRecognizer.location(in: self.collectionView)
            if let indexPath = self.collectionView.indexPathForItem(at: touchPoint)
            {
                weak var weakSelf: ChatLogController? = self
                
                //Already Deleted Message, shouldn't promted with confirmation pop-up
                if self.messages[indexPath.item].message?.deleted == 1 && self.messages[indexPath.item].message?.userId == Auth.auth().currentUser?.uid
                {
                    //Message Already Deleted
                }
                else
                {
                    let deleteAction: AlertButtonWithAction = (.delete, NullableCompletion.init({
                        if let weakSelfN = weakSelf
                        {
                            //In case of Last Message, need to update Conversations too
                            let isLast = (indexPath.item == weakSelfN.messages.count - 1)
                            weakSelfN.messages[indexPath.item].message?.deleteSingleMessage(self.currentConversation!, isLast)
                        }
                    }))
                    
                    let cancelAction: AlertButtonWithAction = (.cancel, nil)
                    self.showAlertWith(message: .custom("Are you sure to delete this message?")!, actions: deleteAction, cancelAction)
                    
                    //                    CustomAlert.sharedInstance.showTwoOptionsAlertWithHandlerAndTitle("Delete", "Are you sure to delete this message?", "Delete", "Cancel", vc: weakSelf)
                    //                    {
                    //                        if let weakSelfN = weakSelf
                    //                        {
                    //                            //In case of Last Message, need to update Conversations too
                    //                            let isLast = (indexPath.item == weakSelfN.messages.count - 1)
                    //                            weakSelfN.messages[indexPath.item].message?.deleteSingleMessage(self.currentConversation!, isLast)
                    //                        }
                    //                    }
                }
            }
        }
    }
    
    func deleteBtnAction(index: Int) {
        
        //In case of Last Message, need to update Conversations too
        let isLast = (index == self.messages.count - 1)
        self.messages[index].message?.deleteSingleMessage(self.currentConversation!, isLast)
    }
    
    //Downloads messages
    func fetchData()
    {
        currentConversation?.downloadMessages()
    }
    
    @objc func singleMessagesLoaded(_ notification: Notification)
    {
        messages = notification.object as? [MessageHandler] ?? []
        collectionView.reloadData()
        if(messages.count > 0)
        {
            self.collectionView.scrollToItem(at: IndexPath(item:self.messages.count-1, section: 0), at: .top, animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            Message.markMessagesRead(self.currentConversation?.conversation?.conversationId ?? "")
        })
    }
    
    @objc func handleKeyboardWillShow(notification : NSNotification){
        
        guard let userInfo = (notification as Notification).userInfo, let _ = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            print("height \(collectionView.frame.height)")
            print("Keyborad size \(keyboardSize.height)")
            //self.containerViewBottomAnchor!.constant = keyboardSize.height
            // self.sendButtonButtom.constant = keyboardSize.height
            collectionView.frame.size = CGSize(width: collectionView.frame.width, height: collectionView.frame.height - keyboardSize.height + 50)
            self.collectionView.scrollToItem(at: IndexPath(item:self.messages.count-1, section: 0), at: .top, animated: true)
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyboardWillHide (notification : NSNotification){
        //move input area
        guard let userInfo = (notification as Notification).userInfo, let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardDuration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        var newHeight: CGFloat = 0
        if #available(iOS 11.0, *) {
            newHeight = value.cgRectValue.height - view.safeAreaInsets.bottom
        } else {
            newHeight = value.cgRectValue.height
        }
        containerViewBottomAnchor?.constant = newHeight
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            print("height \(collectionView.frame.height)")
            print("Keyborad size \(keyboardSize.height)")
            //self.containerViewBottomAnchor!.constant = keyboardSize.height
            // self.sendButtonButtom.constant = keyboardSize.height
            collectionView.frame.size = CGSize(width: collectionView.frame.width, height: (collectionView.frame.height + keyboardSize.height - 50))
            self.collectionView.scrollToItem(at: IndexPath(item:self.messages.count-1, section: 0), at: .top, animated: true)
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = true
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        containerView.backgroundColor = .white
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        
        inputTextField.delegate = self
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView?{
        get {
            return inputContainerView
        }
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    // delegates
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count// userChat_timeStamp.count//messages.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : chatMessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! chatMessageCell
        
        //        let width = estimateFrameForText(text: userChat_text[indexPath.row]).width + 32
        //        print(width)
        //        print(userChat_text[indexPath.row])
        
        // New Code
        
        //--------- **** START
        
        
        let messageInfo = messages[indexPath.row]
        var messageText = ""
        
        if(messageInfo.message?.deleted == 1)
        {
            if (messageInfo.message?.userId == Auth.auth().currentUser?.uid)
            {
                messageText = "You deleted this message"
            }
            else
            {
                messageText = "This message is deleted"
            }
        }
        else
        {
            messageText = messageInfo.message?.msg ?? ""
        }
        
        let senderId = messages[indexPath.row].message?.userId
        let currentUserId = LoginSession.currentUserId
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: messageText).width + 32
        
        cell.textView.text = messageText//message.text
        
        if senderId == currentUserId {
            cell.bubbleView.backgroundColor = UIColor(red: 0/255, green: 137/255, blue: 249/255, alpha: 1)
            cell.textView.textColor = .white
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleViewRightAnchor?.isActive = true
        }
        else{
            cell.bubbleView.backgroundColor = .lightGray
            cell.textView.textColor = .black
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleViewRightAnchor?.isActive = false
        }
        
        // END *****----------
        
        /*
         
         // Uncomment this is new code does not work
         
         cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: userChat_text[indexPath.row]).width + 32
         
         cell.textView.text = userChat_text[indexPath.row]//message.text
         
         let currentUserId = LoginSession.getValueOf(key: SessionKeys.fToken)
         
         if userChat_fromId[indexPath.row] == currentUserId {
         cell.bubbleView.backgroundColor = UIColor(red: 0/255, green: 137/255, blue: 249/255, alpha: 1)
         cell.textView.textColor = .white
         cell.bubbleViewLeftAnchor?.isActive = false
         cell.bubbleViewRightAnchor?.isActive = true
         }
         else{
         cell.bubbleView.backgroundColor = .lightGray
         cell.textView.textColor = .black
         cell.bubbleViewLeftAnchor?.isActive = true
         cell.bubbleViewRightAnchor?.isActive = false
         }
         */
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height : CGFloat = 80
        let messageText = messages[indexPath.row].message?.msg
        
        let text = messageText//userChat_text[indexPath.item]
        height = estimateFrameForText(text: text ?? "").height + 20
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect{
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return  NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)], context: nil)
    }
    
    //MARK:-Functions
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    func setupInputComponents(){
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        //containerView.backgroundColor = .red
        view.addSubview(containerView)
        
        //constraints
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor? .isActive = true
        
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    @objc func handleSend(){
        
        inputTextField.resignFirstResponder()
        
        let text = inputTextField.text?.trim()
        
        if text?.count ?? 0 > 0
        {
            Message.sendMessageToUser(self.recieverUID?.nsnumValue() ?? 0, text ?? "") { (_) in

                //When First Mesage Sent to any user, then need to add Observers
                if self.messages.count == 0
                {
                    self.currentConversation?.removeAndCreateNewMsgAddedRef()
                }
            }
            
            inputTextField.text = ""
        }
        
        //        let currentId = LoginSession.getValueOf(key: SessionKeys.fToken)
                let timeStamp : NSNumber =  NSNumber(value: Int(NSDate().timeIntervalSince1970))
        //
        //        let ref = Database.database().reference().child("messages")
        //        let childRef = ref.childByAutoId()
        //        let values = ["text": inputTextField.text!, "toId": reciever_ftoken!, "fromId" : currentId,"timeStamp": timeStamp ] as [String : Any]
        //        print(values)
        //
        //
        //        childRef.updateChildValues(values) { (error, referenceDB) in
        //            if error != nil {
        //                print(error!.localizedDescription)
        //                return
        //            }
        //            print(referenceDB.key as Any)
        //            let userMessagesRef =  Database.database().reference().child("user-messages").child(currentId)
        //            let messageId = childRef.key
        //            userMessagesRef.updateChildValues([messageId : 1])
        //        }
        //
        //        self.userChat_timeStamp.append(timeStamp)
        //        self.userChat_toId.append(self.reciever_ftoken!)
        //        self.userChat_fromId.append(currentId)
        //        self.userChat_text.append(self.inputTextField.text!)
                let seconds = timeStamp.doubleValue
                let timeStampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a "
                let dateString = dateFormatter.string(from: timeStampDate as Date)
        //
                DispatchQueue.main.async {
                    self.sendPush(txt: self.inputTextField.text!, senderId: self.currentUserFToken,msgDate: dateString)
                    self.collectionView.reloadData()
                }
//                self.inputTextField.text = nil
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if textField.text != "" {
            handleSend()
        }
        return true 
    }
    //
    //    func observeMessages2(){
    //
    //        let uid = LoginSession.getValueOf(key: SessionKeys.fToken)
    //        let ref = Database.database().reference().child("user-messages").child(uid)
    //        ref.observe(.childAdded, with: { (snapshot) in
    //
    //            print(snapshot)
    //
    //            let messageId = snapshot.key
    //            let messagesRef = Database.database().reference().child("messages").child(messageId)
    //
    //            messagesRef.observeSingleEvent(of: .value, with: { (Snapshot) in
    //
    //                print(snapshot )
    //
    //                guard let dic = Snapshot.value as? [String: AnyObject] else{
    //                    return
    //                }
    //
    //                let message = MessageModel()
    //                message.fromId = dic["fromId"] as? String
    //                message.text = dic["text"] as? String
    //                message.timeStamp = dic["timeStamp"] as? NSNumber
    //                message.toId = dic["toId"] as? String
    //
    //                if message.chatPartnerId() == self.reciever_ftoken {
    //                    DispatchQueue.main.async {
    //
    //                        self.userChat_timeStamp.append(message.timeStamp!)
    //                        self.userChat_toId.append(message.toId!)
    //                        self.userChat_fromId.append(message.fromId!)
    //                        self.userChat_text.append(message.text!)
    //
    //                        self.collectionView.reloadData()
    //                    }
    //                }
    //
    //                self.messages.append(message)
    //
    //            }, withCancel: nil)
    //
    //        }, withCancel: nil)
    //    }
    
    
    //    func observeMessages(){
    //
    //        let db = Database.database().reference()
    //        let ref = db.child("messages")
    //
    //        let currentUser_fToken = LoginSession.getValueOf(key: SessionKeys.fToken)
    //
    //        ref.observe(.childAdded, with: { (snapshot) in
    //
    //            if let dic = snapshot.value as? Dictionary<String, AnyObject> {
    //
    //            if (dic["fromId"] as? String == currentUser_fToken && dic["toId"] as? String  == self.reciever_ftoken! || dic["fromId"] as? String  == self.reciever_ftoken! && dic["toId"] as? String  == currentUser_fToken) {
    //
    //                self.allMessagesArray.add(dic)
    //                self.collectionView.reloadData()
    //
    //            }
    //            /*
    //            if let dic = snapshot.value as? [String: AnyObject] {
    //            print(dic.count)
    //
    //                let message = MessageModel()
    //                message.fromId = dic["fromId"] as? String
    //                message.text = dic["text"] as? String
    //                message.timeStamp = dic["timeStamp"] as? NSNumber
    //                message.toId = dic["toId"] as? String
    //
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
    //                    if let toId = message.toId {
    //                        print(toId)
    //                        self.messageDictionary[currentUser_fToken] = message
    //                        self.messages = Array(self.messageDictionary.values)
    //                        print(message.fromId as Any)
    //                        print(self.messageDictionary.count)
    //
    //                        self.chatMessages.append(message)
    //                        self.messages.sort { (message1, message2) -> Bool in
    //                        return message1.timeStamp!.intValue > message2.timeStamp!.intValue
    //                    }
    //                }
    //
    //                    DispatchQueue.main.async {
    //                    // self.updateChat()
    //                    //self.collectionView.reloadData()
    //                    }
    //
    //                }
    //
    //                //message.setValuesForKeys(dic)
    //                // return
    //            }
    //
    //            */
    //            }
    //        }, withCancel: nil)
    //}
    
    
    //    func updateChat(){
    //
    //        print(chat_toId.count)
    //        print(userChat_toId.count)
    //
    //                 userChat_fromId = []
    //                 userChat_text = []
    //                 userChat_timeStamp = []
    //                 userChat_toId = []
    //
    //                let message = messages[chatIndex]
    //                let currentUser_fToken = LoginSession.getValueOf(key: SessionKeys.fToken)
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
    //
    //                    if (chat_toId[index] == message.toId! && chat_fromId[index] == currentUser_fToken) || (chat_toId[index] == currentUser_fToken && chat_fromId[index] == message.toId!) {
    //
    //                        if count > userChat_text.count{
    //                        userChat_text.append(chat_text[index])
    //                        userChat_fromId.append(chat_fromId[index])
    //                        userChat_toId.append(chat_toId[index])
    //                        userChat_timeStamp.append(chat_timeStamp[index])
    //                        }
    //                    }
    //                    if userChat_text.count != count {
    //                        self.collectionView.reloadData()
    //                    }
    //                    print(userChat_text)
    //                }
    //    }
    //
    //    func updateRealtimeChat(){
    //
    //        let db = Database.database().reference()
    //        let ref = db.child("messages")
    //
    //        //DispatchQueue.global(qos: .default).async {
    //
    //        ref.observe(.childAdded, with: { (snapshot) in
    //            print(snapshot.key)
    //            print(snapshot)
    //            if let dic = snapshot.value as? Dictionary<String, AnyObject> {
    //
    //                if (dic["fromId"] as? String == LoginSession.currentUserFToken && dic["toId"] as? String  == self.reciever_ftoken! || dic["fromId"] as? String  == self.reciever_ftoken! && dic["toId"] as? String  == LoginSession.currentUserFToken) {
    //
    //                    self.allMessagesArray.add(dic)
    //                    self.collectionView.reloadData()
    //                }
    //                if self.allMessagesArray.count > 0
    //                {
    //                    print(self.allMessagesArray)
    //
    //                    self.collectionView.scrollToItem(at: IndexPath(item:self.allMessagesArray.count-1, section: 0), at: .top, animated: true)
    //                }
    //
    //
    //                print(dic.count)
    //                /*
    //                for Message in dic {
    //                   print(Message.key)
    //
    //                let msg = dic[Message.key] as? [String: AnyObject]
    //
    //                let message = MessageModel()
    //                message.fromId = msg?["fromId"] as? String
    //                message.text = msg?["text"] as? String
    //                message.timeStamp = msg?["timeStamp"] as? NSNumber
    //                message.toId = msg?["toId"] as? String
    //
    //                print(message.fromId)
    //                print(message.text)
    //                print(message.timeStamp)
    //                print(message.toId)
    //
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
    //                    if let toId = message.toId {
    //                        print(toId)
    //                        self.messageDictionary[currentUser_fToken] = message
    //                        self.messages = Array(self.messageDictionary.values)
    //                        print(message.fromId as Any)
    //                        print(self.messageDictionary.count)
    //
    //                        self.chatMessages.append(message)
    //                        self.messages.sort { (message1, message2) -> Bool in
    //                            return message1.timeStamp!.intValue > message2.timeStamp!.intValue
    //                        }
    //                    }
    //
    //                    DispatchQueue.main.async {
    //                      //  self.updateChat()
    //                        //self.collectionView.reloadData()
    //                    }
    //
    //                }
    //
    //                              //message.setValuesForKeys(dic)
    //                             // return
    //            }
    //                 */
    //
    //            }
    //
    //
    //        }, withCancel: nil)
    //
    //
    //    }
    
    func sendPush(txt:String,senderId:String,msgDate:String)
    {
        let url = UpdateBadge
        
        Alamofire.request(url,  method: .post, parameters: ["id": recieverUID!, "reset": false]).responseJSON { response in
            let value = response.result.value as! [String:Any]?
            let BoolValue = value?["success"] as! Bool
            if(BoolValue == true) {
                let badgeCount = value?["badgeCount"] as! Int
                var request = URLRequest(url: URL(string: "https://fcm.googleapis.com/fcm/send")!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("key=AAAA_QjVv44:APA91bEpd8HIWReOMvyPT_vtT-hPB4P6nHJqjNmnAKGL-ZTDEH0L9ptEUQ8bVQzllbAhQiiaHQ3_EFdoCqO1xbdxP1v5TNXG2_qtvgMwwZ8n-vAHPJWIv__PI7PPUO8AjNoQremscAma", forHTTPHeaderField: "Authorization")
                let json = [
                    "to" : self.reciever_ftoken! as String,
                    "priority" : "high","message":txt,"mSender_id":senderId,"sound":"enabled",
                    "notification" : [
                        "body":"You Have a New Message","badge":badgeCount, "mSender_id":senderId,"sound": "default"
                    ],"data" : [
                        "message" : txt,"mSender_id":senderId,"mReciver_id":self.reciever_ftoken,"date":msgDate,"mPost_id":self.currentUserFToken,
                    ]
                    ] as [String : Any]
                
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
    
}


