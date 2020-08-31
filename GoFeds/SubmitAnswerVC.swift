//
//  SubmitAnswerVC.swift
//  GoFeds
//

import UIKit
import Alamofire
import SwiftyJSON

class SubmitAnswerVC: UIViewController {
    
    @IBOutlet weak var txtAnswer : UITextView!
    var questionData = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtAnswer.layer.cornerRadius = 8
        txtAnswer.clipsToBounds = true
        // txtAnswer.becomeFirstResponder()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func submitAnswer() {
        Utility.showActivityIndicator()
        let url = SubmitFAQAnswerUrl
        let newAnswerTxt = txtAnswer.text.replacingOccurrences(of: "'", with: "\\'")
        
        Alamofire.request(url,  method: .post, parameters: ["question_id" : (questionData["question_id"] as! String),"user_id":(LoginSession.currentUserId),"answer":newAnswerTxt, "vote":0]).responseJSON { response in
            
            let value = response.result.value as! [String:Any]?
            let BoolValue = value?["success"] as! Bool
            print(value!)
            if(BoolValue == true) {
                
                let msg = value!["message"] as! String
                //                if msg == "Answer already submitted for this Question."{
                Utility.hideActivityIndicator()
                self.dismiss(animated: true, completion: nil)
                //
                                    NotificationCenter.default.post(name: .updateDesiredPorts, object: self)
                //                   // self.dismiss(animated: true, completion: nil)
                //                    let okAction: AlertButtonWithAction = (.ok, nil)
                //                                   self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
                //                }
            }else {
                Utility.hideActivityIndicator()
                let okAction: AlertButtonWithAction = (.ok, nil)
                self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
            }
        }
    }
    
    @IBAction func onClickClose() {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onClickSubmit() {
        if txtAnswer.text == "" {
            let okAction: AlertButtonWithAction = (.ok, nil)
            self.showAlertWith(message: .custom("\("Enter your answer")"), actions: okAction)
        }
        else {
            submitAnswer()
        }
    }
    
}
