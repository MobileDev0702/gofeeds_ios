//
//  SignUpVC.swift
//  GoFeds
//
//  Created by Novos on 17/04/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase
import FirebaseAuth
import FirebaseFirestore

var portType = ""

class SignUpVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK:- IBOutlets
    @IBOutlet weak var lastNameTextfield: UITextField!
    @IBOutlet weak var passwrdTextfld: UITextField!
    @IBOutlet weak var emailTextfld: UITextField!
    @IBOutlet weak var selectRankBtn: UIButton!
    @IBOutlet weak var rankTextfld: UITextField!
    @IBOutlet weak var selectAgencyBtn: UIButton!
    @IBOutlet weak var agencyTextfld: UITextField!
    @IBOutlet weak var selectOfficeBtn: UIButton!
    @IBOutlet weak var officeTextfld: UITextField!
    @IBOutlet weak var currentPortTextFld: UITextField!
    @IBOutlet weak var currentPortBtn: UIButton!
    @IBOutlet weak var desiredPortTextfld: UITextField!
    @IBOutlet weak var desiredPortBtn: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var termsView: UIView!
    
    //@IBOutlet weak var baseViewHeight: NSLayoutConstraint!
    
    //MARK:- Variables
    var rankPicker  = UIPickerView()
    var agencyPicker  = UIPickerView()
    var officePicker = UIPickerView()
    var currentPortPicker = UIPickerView()
    var toolBar = UIToolbar()
    
    let Ranks = ["GS-1","GS-2","GS-3","GS-4","GS-5","GS-6","GS-7","GS-8","GS-9","GS-10","GS-11","GS-12","GS-13","GS-14","GS-15","Other"]
    let Agencies = ["CBP"]
    let Officies = ["OFO","BP"]
    let currPort = "AZ San Ysidrdo"
    
    //MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
             selector: #selector(updateDesiredPort),
             name: .updateDesiredPorts,
             object: nil)
//        currentPortTextFld.text = currPort
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
       
    }
    
    override func viewDidLayoutSubviews() {
//        baseViewHeight.constant = 500
    }
    
    //MARK:- Button Actions
    @IBAction func selectRankBtn(_ sender: Any) {
        removeFromSuper()
        rankPicker = UIPickerView.init()
        rankPicker.delegate = self
        rankPicker.backgroundColor = UIColor.white
        rankPicker.setValue(UIColor.black, forKey: "textColor")
        rankPicker.autoresizingMask = .flexibleWidth
        rankPicker.contentMode = .center
        rankPicker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 230, width: UIScreen.main.bounds.size.width, height: 230)
        self.view.addSubview(rankPicker)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 230, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        self.view.addSubview(toolBar)
    }
    
    @IBAction func selectAgencyBtn(_ sender: Any) {
        removeFromSuper()
        agencyPicker = UIPickerView.init()
        agencyPicker.delegate = self
        agencyPicker.backgroundColor = UIColor.white
        agencyPicker.setValue(UIColor.black, forKey: "textColor")
        agencyPicker.autoresizingMask = .flexibleWidth
        agencyPicker.contentMode = .center
        agencyPicker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 230, width: UIScreen.main.bounds.size.width, height: 230)
        self.view.addSubview(agencyPicker)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 230, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        self.view.addSubview(toolBar)
        
    }
    
    @IBAction func selectOfficeBtn(_ sender: Any) {
        removeFromSuper()
        officePicker = UIPickerView.init()
        officePicker.delegate = self
        officePicker.backgroundColor = UIColor.white
        officePicker.setValue(UIColor.black, forKey: "textColor")
        officePicker.autoresizingMask = .flexibleWidth
        officePicker.contentMode = .center
        officePicker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 230, width: UIScreen.main.bounds.size.width, height: 230)
        self.view.addSubview(officePicker)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 230, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        self.view.addSubview(toolBar)
        
    }
   
    @IBAction func selectDesiredBtn(_ sender: Any) {
         // Handling Current Port & Desired Port in Same func
        
        let port : UIButton = sender as! UIButton
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "multiSelectionPopUpVC") as? multiSelectionPopUpVC
        switch port.tag {
        case 10:
            portType = "current"
            selectedType = .current
        default:
            selectedType = .desired
            portType = "desired"
        }
       
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.present(vc!, animated: true, completion: nil)
        
    }
    
    @objc func onDoneButtonTapped() {
        print("Done Button Clicked")
        removeFromSuper()
    }
    
    func removeFromSuper(){
        toolBar.removeFromSuperview()
        rankPicker.removeFromSuperview()
        officePicker.removeFromSuperview()
        agencyPicker.removeFromSuperview()
    }
    
    
    @IBAction func submitActions(_ sender: Any) {
        let validEmailAddressValidationResult = isValidEmailAddress(emailAddressString: emailTextfld.text ?? "")
        if (validEmailAddressValidationResult == false)  {
            let okAction: AlertButtonWithAction = (.ok, nil)
            self.showAlertWith(message: .custom("Enter the valid Email address")!, actions: okAction)
        }else if emailTextfld.text == "" {
            let okAction: AlertButtonWithAction = (.ok, nil)
            self.showAlertWith(message: .custom("Enter the Email address")!, actions: okAction)
        }else if lastNameTextfield.text == ""{
            let okAction: AlertButtonWithAction = (.ok, nil)
            self.showAlertWith(message: .custom("Enter the last Name")!, actions: okAction)
        }else if rankTextfld.text == "" {
            let okAction: AlertButtonWithAction = (.ok, nil)
            self.showAlertWith(message: .custom("Choose the Rank")!, actions: okAction)
        }else if agencyTextfld.text == ""{
            let okAction: AlertButtonWithAction = (.ok, nil)
            self.showAlertWith(message: .custom("Choose the Agency")!, actions: okAction)
        }else if officeTextfld.text == "" {
            let okAction: AlertButtonWithAction = (.ok, nil)
            self.showAlertWith(message: .custom("Choose the Office")!, actions: okAction)
        }else if passwrdTextfld.text == "" {
            let okAction: AlertButtonWithAction = (.ok, nil)
            self.showAlertWith(message: .custom("Enter the Password")!, actions: okAction)
        }else {
            
            //FireBase
//            termsView.isHidden = false
            handleFirebaseRegistration()
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //MARK:- Notification handler
    @objc func updateDesiredPort(notification: Notification){
        let desiredPortVC = notification.object as! multiSelectionPopUpVC
        
        //for port in seletedDesiredPorts
        
        if portType == "current"{
            self.currentPortTextFld.text = selectedCurrentPort
            return
        }
        
        var ports = ""
        var portsArray :[String] = []
        if selectedMultiPortIndexes.count > 0 {
            
            for index in selectedMultiPortIndexes {
                
                var desired = currentPort[index]
                
                portsArray.append(desired)
                
            }
            
            ports = portsArray.joined(separator: ",")
        }
        
        self.desiredPortTextfld.text = ports
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case rankPicker:
            return Ranks.count
        case agencyPicker:
            return Agencies.count
        case officePicker:
            return Officies.count
       
        default:
            return 0
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView {
        case rankPicker:
            return Ranks[row]
        case agencyPicker:
            return Agencies[row]
        case officePicker:
            return Officies[row]
        
        default:
            return "Invalid Request"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case rankPicker:
            rankTextfld.text = Ranks[row]
//            removeFromSuper()
        case agencyPicker:
            agencyTextfld.text = Agencies[row]
//            removeFromSuper()
        case officePicker:
            officeTextfld.text = Officies[row]
//            removeFromSuper()
        default:
            print("Invalid Request")
        }
    }
    @IBAction func onClickCloseBtn(_ sender: UIButton) {

//        handleFirebaseRegistration()
        termsView.isHidden = true
    }
    
    //MARK:- Handle irebase Registration
    
    func handleFirebaseRegistration(){
        
        var uId : String? = ""
        let email = emailTextfld.text!
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: passwrdTextfld.text!) { (result, error) in
            if error != nil {
                 let okAction: AlertButtonWithAction = (.ok, nil)
                self.showAlertWith(message: .custom(error!.localizedDescription)!, actions: okAction)
                
                return
            }
            
            let firebaseUser = result?.user
            uId = firebaseUser?.uid
            
            let dataBase = Database.database().reference(fromURL: GoFedsFirebase.realTimeDatabaseURL)
            let usersReference = dataBase.child("users").child(uId!)
            
            let name = self.lastNameTextfield.text!
            let values = ["name": name,"email": email]
            
            usersReference.updateChildValues(values, withCompletionBlock : {
                (err, ref) in
                
                if err != nil {
                    print("error")
                    return
                }
                //user saved
            })
            
            self.signUp(uid: uId!)
            
        }
        
    }
    
    func signUp(uid : String){
        
        let url = registerUrl
        
        let Params = ["email": "\(emailTextfld.text!)",
                      "username":"\(lastNameTextfield.text!)",
                      "firstname":"hello",
                      "lastname":"hello",
                      "password":"\(passwrdTextfld.text!)",
                      "rank": "\(rankTextfld.text!)",
                      "agency":"\(agencyTextfld.text!)",
                      "current_port":"\(currentPortTextFld.text!)",
                      "desire_port":"\(desiredPortTextfld.text!)",
                      "office":officeTextfld.text!,
                      "ftoken":uid,
                      "device_id":"test"] as [String : Any]
                   
                   Utility.showActivityIndicator()
                   print("url----------------: \(url)")
                   Alamofire.request(url,  method: .post, parameters:Params).responseJSON { response in
                       
                       print(Params)
                       
                       let value = response.result.value as! [String:Any]?
                       
                       Utility.hideActivityIndicator()
                       print(value as Any)
                       
                       let BoolValue = value?["success"] as! Bool
                       if(BoolValue == true) {
                           
                           
                            _ = CurrentUserInfo(dict: value! as NSDictionary)
                           
                        //let firstName = value!["firstname"] as! String
                        //let lastName = value!["lastname"] as! String
                        let userName = value!["username"] as! String
                        let showID = Int(value!["id"] as! NSNumber)
                        let currentPort = value?["current_port"] as! String
                        let desiredPort = value?["desire_port"] as! String
                        let rank = value?["rank"] as! String
                        let agency = value?["agency"] as! String
                        let ftoken = value?["ftoken"] as! String
                        let email = self.emailTextfld.text!
                        let office = value!["office"] as! String
                                              
                        LoginSession.start(ftoken: ftoken, userName: userName, email: email, showId: "\(showID)", desiredPort: desiredPort, rank: rank, agency: agency, currentPort: currentPort,office:office)
                           
                        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBarVC") as? TabBarVC
                        self.navigationController?.isNavigationBarHidden = true
                        self.navigationController?.pushViewController(vc!, animated: true)
                           
                       }
                       else {
                           let okAction: AlertButtonWithAction = (.ok, nil)
                           self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
                       }
                   }
    }
    
    
}
