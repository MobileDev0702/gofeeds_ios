//
//  ForumVC.swift
//  GoFeds
//
//  Created by Novos on 22/04/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ForumVC: UIViewController , QuestionSubmittedDelegate {
    
    //MARK:- IBOutlets
    @IBOutlet weak var forumTable: UITableView!
    @IBOutlet weak var forumSearchBar: UIImageView!
    @IBOutlet weak var addBtn: UIButton!
    
    
    
    //MARK:- Variables
    var listArray = NSArray()
    
    //MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        forumTable.separatorStyle = .none
        getAllForumList()
        
    }
    
    func getAllForumList() {
        Utility.showActivityIndicator()
        let url = ViewFAQUrl
        Alamofire.request(url,  method: .post, parameters: nil).responseJSON { response in
            let value = response.result.value as! [String:Any]?
            
            print("\n\n\n  Forum Data")
//             print(value!)
            let BoolValue = value?["success"] as! Bool
           
            if(BoolValue == true) {
                Utility.hideActivityIndicator()
                self.listArray = value?["data"] as! NSArray
                self.forumTable.reloadData()
            }else {
                Utility.hideActivityIndicator()
                let okAction: AlertButtonWithAction = (.ok, nil)
                self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
            }
        }
    }
    
    func newQuestionAdded() {
        getAllForumList()
    }
    
    
    //MARK:- Button Actions
    @IBAction func onClickAdd() {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AddQuestionVC") as? AddQuestionVC
        vc?.delegate = self
        self.present(vc!, animated: true, completion: nil)
    }
    
}
//MARK:- TableView Delegates & DataSource
extension ForumVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CommonTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let data = listArray.object(at: indexPath.row) as! NSDictionary
//        cell.forumLabel1.text  = (data["question"] as! String)
        cell.forumLabel2.text  = (data["question"] as! String)
        cell.txtForumAnswer.text  = (data["answer"] as! String)
        cell.nameTextLbl.text = (data["username"] as! String)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
//        let data = listArray.object(at: indexPath.row) as! NSDictionary
//
//        let answer  = (data["answer"] as! String)
//        let question  = (data["question"] as! String)
//
//
//        let constraintRect = CGSize(width: self.view.frame.height - 100, height: .greatestFiniteMagnitude)
//        let font = UIFont.systemFont(ofSize: 12.0)
//
//        let boundingBox = answer.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
//        let answerHeight =  ceil(boundingBox.height)
//
//
//        let questionfont = UIFont.boldSystemFont(ofSize: 20)
//        let boundingBox1 = question.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: questionfont], context: nil)
//        let questionHeight =  ceil(boundingBox1.height)
        return UITableView.automaticDimension
        
        
//        return 100.0 + answerHeight + questionHeight

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = listArray.object(at: indexPath.row) as! NSDictionary
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ForumAnswerListVC") as? ForumAnswerListVC
        vc?.questionData = data
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
