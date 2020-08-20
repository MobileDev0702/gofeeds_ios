//
//  AddQuestionVC.swift
//  GoFeds
//
//  Created by Tarun Sachdeva on 07/05/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol QuestionSubmittedDelegate: class {
    func newQuestionAdded()
}

class AddQuestionVC: UIViewController , UITextViewDelegate {

    @IBOutlet weak var txtQuestion : UITextView!
    weak var delegate: QuestionSubmittedDelegate? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtQuestion.text = "Add your question here"
        txtQuestion.textColor = UIColor.black
        txtQuestion.backgroundColor = UIColor.white
        
        txtQuestion.layer.cornerRadius = 4.0
        txtQuestion.layer.borderColor = UIColor.black.cgColor
        txtQuestion.layer.borderWidth = 1.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Add your question here"{
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add your question here"
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count <= 170 {
            txtQuestion.layer.borderColor = UIColor.black.cgColor
        } else {
            txtQuestion.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    @IBAction func onClickClose() {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onClickSubmit() {
        if (txtQuestion.text == "Add your question here" || txtQuestion.text == "") {
           
            let okAction: AlertButtonWithAction = (.ok, nil)
            self.showAlertWith(message: .custom("Please enter your question"), actions: okAction)
            
        }
        else {
            if txtQuestion.text.count <= 170 {
                addForumQuestion()
            } else {
                let okAction: AlertButtonWithAction = (.ok, nil)
                self.showAlertWith(message: .custom("Question should be less than 170 characters!"), actions: okAction)
            }
        }
    }
    
    func addForumQuestion() {
        Utility.showActivityIndicator()
        let userID = UserDefaults.standard.value(forKey: SessionKeys.showId) as! String
        let url = AddFAQUrl
        
        Alamofire.request(url,  method: .post, parameters: ["user_id": userID, "question": "\(txtQuestion.text!)"]).responseJSON { response in
            let value = response.result.value as! [String:Any]?
            let BoolValue = value?["success"] as! Bool
            print(value!)
            if(BoolValue == true) {
                Utility.hideActivityIndicator()
                self.delegate?.newQuestionAdded()
                self.dismiss(animated: true, completion: nil)
            }else {
                Utility.hideActivityIndicator()
                let okAction: AlertButtonWithAction = (.ok, nil)
                self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
            }
        }
    }
    
}
