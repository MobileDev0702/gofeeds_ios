//
//  ForumAnswerListVC.swift
//  GoFeds
//

import UIKit
import Alamofire
import SwiftyJSON

class ForumAnswerListVC: UIViewController {

    @IBOutlet weak var txtQuestion: UITextView!
    @IBOutlet weak var forumTable: UITableView!
    var listArray = NSArray()
    var questionData = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtQuestion.text = (questionData["question"] as! String)
        NotificationCenter.default.addObserver(self,
                    selector: #selector(updateAnswers),
                    name: .updateDesiredPorts,
                    object: nil)
        getAllAnswerList()
    }
    
    //MARK:- Notification handler
    @objc func updateAnswers(notification: Notification){
        getAllAnswerList()
    }
    
    func getAllAnswerList() {
        Utility.showActivityIndicator()
        let url = ViewAllAnswerOfQuestionUrl
        Alamofire.request(url,  method: .post, parameters: ["question_id" : (questionData["question_id"] as! String)]).responseJSON { response in
            let value = response.result.value as! [String:Any]?
            let BoolValue = value?["success"] as! Bool
            print(value!)
            if(BoolValue == true) {
                Utility.hideActivityIndicator()
                self.listArray = value?["answers"] as! NSArray
                self.forumTable.reloadData()
            }else {
                Utility.hideActivityIndicator()
                let okAction: AlertButtonWithAction = (.ok, nil)
                let msg = value!["message"] as! String
                if msg == "No Questions Found"{
                    self.showAlertWith(message: .custom("No answer found")!, actions: okAction)
                }
                else{
                     self.showAlertWith(message: .custom(msg)!, actions: okAction)
                }
                
                self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
            }
        }
    }
    
    @IBAction func onClickBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSubmitAnswerAcn() {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SubmitAnswerVC") as? SubmitAnswerVC
        vc!.questionData = questionData
        self.present(vc!, animated: true, completion: nil)
        Utility.hideActivityIndicator()
    }
    
    @IBAction func onClickUpVoteBtn(_ sender: UIButton) {
        let indexP = IndexPath(row: sender.tag, section: 0)
        let cell = forumTable.cellForRow(at: indexP) as! CommonTableViewCell
        let data = listArray.object(at: indexP.row) as! NSDictionary
        
        let url = UpdateVote
        
        Alamofire.request(url,  method: .post, parameters: ["id": data["answer_id"] as! String, "vote": Int(cell.voteLabel.text!)! + 1, "question_id": (questionData["question_id"] as! String), "user_id":(LoginSession.currentUserId)]).responseJSON { response in
            let value = response.result.value as! [String:Any]?
            let BoolValue = value?["success"] as! Bool
            if(BoolValue == true) {
                let voteInt = Int(cell.voteLabel.text!)! + 1
                cell.voteLabel.text = "\(voteInt)"
                self.listArray = value?["answers"] as! NSArray
                self.forumTable.reloadData()
            }else {
                let okAction: AlertButtonWithAction = (.ok, nil)
                self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
            }
        }
    }
    
    @IBAction func onClickDownVoteBtn(_ sender: UIButton) {
        let indexP = IndexPath(row: sender.tag, section: 0)
        let cell = forumTable.cellForRow(at: indexP) as! CommonTableViewCell
        let data = listArray.object(at: indexP.row) as! NSDictionary
        
        if (Int(cell.voteLabel.text!)! - 1) > -1 {
            let url = UpdateVote
            
            Alamofire.request(url,  method: .post, parameters: ["id": data["answer_id"] as! String, "vote": Int(cell.voteLabel.text!)! - 1, "question_id": (questionData["question_id"] as! String), "user_id":(LoginSession.currentUserId)]).responseJSON { response in
                let value = response.result.value as! [String:Any]?
                let BoolValue = value?["success"] as! Bool
                if(BoolValue == true) {
                    let voteInt = Int(cell.voteLabel.text!)! - 1
                    cell.voteLabel.text = "\(voteInt)"
                    self.listArray = value?["answers"] as! NSArray
                    self.forumTable.reloadData()
                }else {
                    let okAction: AlertButtonWithAction = (.ok, nil)
                    self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
                }
            }
        }
    }
    
}


//MARK:- TableView Delegates & DataSource
extension ForumAnswerListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CommonTableViewCell
        let data = listArray.object(at: indexPath.row) as! NSDictionary
        cell.answernameLbl.text = (data["username"] as! String)
        cell.lblAnswer.text  = (data["answer"] as! String)
        cell.voteLabel.text = (data["vote"] as! String)
        cell.upvoteBtn.tag = indexPath.row
        cell.downvoteBtn.tag = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = listArray.object(at: indexPath.row) as! NSDictionary
        let answer =   (data["answer"] as! String)
        let setFont =  UIFont(name: "Helvetica", size: 20)
        return heightForView(text: answer, font: setFont!, width: view.frame.width - 140) + 60
    }
    
     func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = UIFont(name: "Helvetica", size: 17)
        label.text = text

        label.sizeToFit()
        return label.frame.height
    }

   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = MyProfileUrl
        let data = listArray.object(at: indexPath.row) as! NSDictionary
        Alamofire.request(url,  method: .post, parameters: ["user_id": data["user_id"] as! String]).responseJSON { response in
            let value = response.result.value as! [String:Any]?
            let BoolValue = value?["success"] as! Bool
            if(BoolValue == true) {
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MyProfileVC") as? MyProfileVC
                vc!.userData = value! as NSDictionary
    //            self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.pushViewController(vc!, animated: true)
            }else {
                let okAction: AlertButtonWithAction = (.ok, nil)
                self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
            }
        }
    }

}
