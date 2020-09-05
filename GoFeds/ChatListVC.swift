//
//  ChatListVC.swift
//  GoFeds
//
//  Created by WuSongBai on 2020/9/4.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ChatListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var chatListTableView: UITableView!
    var dbRef: DatabaseReference!
    
    struct UserInfo {
        var id: String
        var username: String
        var msg: String
        var conversationId: String
        var time: String
    }
    
    var userList = [UserInfo]()
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initFirebase()
        initData()
        loadChatList()
    }
    
    func initFirebase() {
        dbRef = Database.database().reference()
    }
    
    func initData() {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func loadChatList() {
        Utility.showActivityIndicator()
        dbRef.child("messages").child("chatUsers").child(LoginSession.currentUserId).observeSingleEvent(of: .value) { (snapshot) in
            if let snapshotValue = snapshot.value as? [String: Any] {
                for child in snapshotValue {
                    if let childValue = child.value as? [String: Any] {
                        let receiverId = childValue["receiverId"] as! Int
                        let receiverUser = childValue["receiverUser"] as! String
                        let lastMsg = childValue["lastMessage"] as! String
                        let conversationId = childValue["conversationId"] as! String
                        let timestamp = childValue["lastMessageTimeStamp"] as! Int
                        let timeNum = NSNumber(value:timestamp)
                        let date = Date.dateFromTimeInterval(timeNum)
                        let user = UserInfo(id: "\(receiverId)", username: receiverUser, msg: lastMsg, conversationId: conversationId, time: date)
                        self.userList.append(user)
                    }
                }
                Utility.hideActivityIndicator()
                self.chatListTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CommonTableViewCell
        
        cell.chatUsername.text = userList[indexPath.row].username
        cell.userMessage.text = userList[indexPath.row].msg
        cell.userDate.text = userList[indexPath.row].time
        cell.backVW.bottomMaskViewShadow()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        self.performSegue(withIdentifier: "ChatListToDetailVC", sender: nil)
    }
    
    @IBAction func onClickBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ChatListToDetailVC" {
            if let destinationVC = segue.destination as? ChatDetailController {
                destinationVC.roomId = userList[selectedIndex].conversationId
                destinationVC.receiverId = userList[selectedIndex].id
                destinationVC.receiverUser = userList[selectedIndex].username
            }
        }
    }
    

}
