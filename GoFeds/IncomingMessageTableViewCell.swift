//
//  IncomingMessageTableViewCell.swift
//  GoFeds
//
//  Created by WuSongBai on 2020/9/4.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import FirebaseDatabase

class IncomingMessageTableViewCell: UITableViewCell, MessageCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var textBubble: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var textBubblePointer: UIImageView!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    
    var dbRef: DatabaseReference = Database.database().reference()
    
    private enum Constants {
      static let shadowColor = UIColor(red: 189 / 255, green: 204 / 255, blue: 215 / 255, alpha: 0.54)
      static let shadowRadius: CGFloat = 2
      static let shadowOffset = CGSize(width: 0, height: 1)
      static let chainedMessagesBottomMargin: CGFloat = 20
      static let lastMessageBottomMargin: CGFloat = 32
    }
    
    var message: MessageInfo? {
      didSet {
        guard let message = message else {
          return
        }
//          dbRef.child("user").child(message.senderId).observeSingleEvent(of: .value) { (snapshot) in
//              if let snapshotValue = snapshot.value as? [String: Any] {
//                  let photoUrl = snapshotValue["photo"] as! String
//                  if photoUrl.isEmpty {
//                      self.userImage.image = UIImage(named: "avatar")
//                  } else {
//                      self.userImage.sd_setImage(with: URL(string: photoUrl), completed: nil)
//                  }
//              }
//          }
        self.userImage.sd_setImage(with: URL(string: "http://stackrage.com/gofeeds/images/\(message.avatar)"), completed: nil)
        contentLabel.text = message.content
      }
    }
    
    var showsAvatar = true {
      didSet {
        userImage.isHidden = !showsAvatar
        textBubblePointer.isHidden = !showsAvatar
        bottomMargin.constant = showsAvatar ? Constants.lastMessageBottomMargin : Constants.chainedMessagesBottomMargin
      }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textBubble.layer.cornerRadius = 6
        textBubble.layer.addShadow(
          color: Constants.shadowColor,
          offset: Constants.shadowOffset,
          radius: Constants.shadowRadius)
        userImage.layer.cornerRadius = userImage.bounds.height / 2
        userImage.layer.borderWidth = 1
        userImage.layer.borderColor = UIColor.black.cgColor
        userImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
