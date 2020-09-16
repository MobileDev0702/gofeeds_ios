//
//  ForgotPwdVC.swift
//  GoFeds
//
//  Created by WuSongBai on 2020/9/10.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import SwiftSMTP

class ForgotPwdVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    let smtp = SMTP(hostname: "smtp.gmail.com",
                    email: "fedsconnect@gmail.com",
                    password: "HOTdogs#1")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSendBtn(_ sender: UIButton) {
        Utility.showActivityIndicator()
        let from = Mail.User(name: "noreply", email: "fedsconnect@gmail.com")
        let to = Mail.User(name: "FedsConnect", email: self.emailTextField.text!)
        
        let mail = Mail(from: from,
                        to: [to],
                        subject: "Reset Password",
                        text: "follow this link to reset pasword.\nhttp://stackrage.com/gofeeds/reset_password.php?email=\(self.emailTextField.text!)")
        smtp.send(mail) { (error) in
            if let error = error {
                DispatchQueue.main.async {
                    let okAction: AlertButtonWithAction = (.ok, nil)
                    self.showAlertWith(message: .custom(error.localizedDescription)!, actions: okAction)
                }
            } else {
                let okAction: AlertButtonWithAction = (.ok, nil)
                self.showAlertWith(message: .custom("Successfully sent link!")!, actions: okAction)
            }
            Utility.hideActivityIndicator()
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
