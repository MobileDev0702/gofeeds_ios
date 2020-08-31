//
//  CommonTableViewCell.swift
//  GoFeds
//

import UIKit

class CommonTableViewCell: UITableViewCell {
    
    //MARK:- ChatVC
    @IBOutlet weak var chatUsername: UILabel!
    @IBOutlet weak var userMessage: UILabel!
    @IBOutlet weak var userProfile: UIImageView!
    @IBOutlet weak var userDate: UILabel!
    @IBOutlet weak var backVW: UIView!
    
    //MARK:- ConnectionVC
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var connectProfile: UIImageView!
    @IBOutlet weak var connectUsername: UILabel!
    @IBOutlet weak var connectionPortName: UILabel!
    
    //MARK:- ForumVC
    @IBOutlet weak var forumLabel1: UILabel!
    @IBOutlet weak var forumLabel2: UILabel!
    @IBOutlet weak var forumLabel3: UILabel!
    @IBOutlet weak var forumLabel4: UILabel!
    @IBOutlet weak var txtForumAnswer: UILabel!
//    @IBOutlet weak var txtForumAnswer: UITextView!
    @IBOutlet weak var forumImg: UIImageView!
    @IBOutlet weak var mainQuestionHeight: NSLayoutConstraint!
    @IBOutlet weak var userQuestionHeight: NSLayoutConstraint!
    @IBOutlet weak var userAnswerHeight: NSLayoutConstraint!
    @IBOutlet weak var nameTextLbl: UILabel!
    @IBOutlet weak var answernameLbl: UILabel!
    
    //MARK:- NewsFeedVC
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var newsHeadline: UILabel!
    @IBOutlet weak var newsPostTime: UILabel!
    @IBOutlet weak var NewsVW: UIView!
    
    //MARK:- Forum Answers
    @IBOutlet weak var lblAnswer: UILabel!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var upvoteBtn: UIButton!
    @IBOutlet weak var downvoteBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
