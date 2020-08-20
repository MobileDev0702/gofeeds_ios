//
//  LoginVC.swift
//  GoFeds
//
//  Created by Novos on 20/04/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginVC: UIViewController {
    
    var window: UIWindow?
    //MARK:- IBOutlets
    @IBOutlet weak var emailAddressText: UITextField!
    @IBOutlet weak var psswrdTextfld: UITextField!
    @IBOutlet weak var forgetPasswrdBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    //MARK:- Variables
    
    
    //MARK:- ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailAddressText.text = ""//"kamal@gmail.com"
        psswrdTextfld.text = ""//"123456"
        
        if LoginSession.isActive(){
            self.navigateToHome()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func navigateToHome() {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBarVC") as? TabBarVC
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    //MARK:- Button Actions
    @IBAction func forgetPasswrdBtn(_ sender: Any) {
        
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        
        weak var weakSelf = self
        
        let validEmailAddressValidationResult = isValidEmailAddress(emailAddressString: emailAddressText.text ?? "")
        //        if (validEmailAddressValidationResult == false)  {
        //            let okAction: AlertButtonWithAction = (.ok, nil)
        //            self.showAlertWith(message: .custom("Enter the valid Email address")!, actions: okAction)
        //        }else
        if emailAddressText.text == "" {
            let okAction: AlertButtonWithAction = (.ok, nil)
            self.showAlertWith(message: .custom("Enter the Email address")!, actions: okAction)
        }else if psswrdTextfld.text == "" {
            let okAction: AlertButtonWithAction = (.ok, nil)
            self.showAlertWith(message: .custom("Enter the Password")!, actions: okAction)
        }else {
            Utility.showActivityIndicator()
            let url = loginUrl
            Alamofire.request(url,  method: .post, parameters: ["username":"\(emailAddressText.text!)", "password":"\(psswrdTextfld.text!)", "device_id": "shdjshdjs"]).responseJSON { response in
                
                DispatchQueue.main.async {
                    
                    let value = response.result.value as! [String:Any]?
                    if value == nil {
                        Utility.hideActivityIndicator()
                        let okAction: AlertButtonWithAction = (.ok, nil)
                        self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
                        return
                    }
                    let BoolValue = value?["success"] as! Bool
                    if(BoolValue == true) {
                        print(value!)
                        
                        _ = CurrentUserInfo(dict: value! as NSDictionary)
                        
                        // let firstName = value!["firstname"] as! String
                        //let lastName = value!["lastname"] as! String
                        let userName = value!["username"] as! String
                        let showID = value!["id"] as! String
                        let currentPort = value?["current_port"] as! String
                        let desiredPort = value?["desire_port"] as! String
                        let rank = value?["rank"] as! String
                        let agency = value?["agency"] as! String
                        let ftoken = value?["ftoken"] as! String
                        var office = ""
                        if  value?["office"] != nil {
                            office = value?["office"] as! String
                        }
                        let email = self.emailAddressText.text!
                        
                        LoginSession.start(ftoken: ftoken, userName: userName, email: email, showId: showID, desiredPort: desiredPort, rank: rank, agency: agency, currentPort: currentPort, office: office)
                        
                        // Clrar Trextfields
                        weakSelf?.emailAddressText.text = ""
                        weakSelf?.psswrdTextfld.text = ""
                        
                        Utility.hideActivityIndicator()
                        weakSelf?.navigateToHome()
                    }else {
                        Utility.hideActivityIndicator()
                        let okAction: AlertButtonWithAction = (.ok, nil)
                        weakSelf?.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
                    }
                }
            }
        }
    }
    
    @IBAction func signUpBtn(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignUpVC") as? SignUpVC
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    
}
