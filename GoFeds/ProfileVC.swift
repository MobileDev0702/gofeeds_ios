//
//  ProfileVC.swift
//  GoFeds
//

import UIKit
import Alamofire
import SwiftyJSON

class ProfileVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //MARK:- IBOutlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var rankTextFld: UITextField!
    @IBOutlet weak var agencyTextFld: UITextField!
    @IBOutlet weak var officeTextfld: UITextField!
    @IBOutlet weak var currentPortTxtFld: UITextField!
    @IBOutlet weak var desiredTextFld: UITextField!
    @IBOutlet weak var saveBtn: GradientButton!
    
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
    
    var imagePicker: UIImagePickerController!
    private var imageToUpload: UIImage?
    private var imageToUploadURL: String?
    
    //MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
             selector: #selector(updateDesiredPort),
             name: .updateDesiredPorts,
             object: nil)
//        currentPortTxtFld.text = currPort
        apiCall()
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func initUI() {
        userImage.layer.cornerRadius = userImage.frame.size.height / 2
        userImage.layer.borderColor = UIColor.white.cgColor
        userImage.layer.borderWidth = 1
        userImage.clipsToBounds = true
    }
    
    //MARK:- Button Actions
    
    func apiCall(){
        Utility.showActivityIndicator()
        let url = MyProfileUrl
        let myID = UserDefaults.standard.integer(forKey: SessionKeys.showId)
        
        Alamofire.request(url,  method: .post, parameters: ["user_id": myID]).responseJSON { response in
            let value = response.result.value as! [String:Any]?
            let BoolValue = value?["success"] as! Bool
            if(BoolValue == true) {
                let agency = value?["agency"] as! String
                let current_port = value?["current_port"] as! String
                let desire_port = value?["desire_port"] as! String
                let office = value?["office"] as! String
                let rank = value?["rank"] as! String
                let myName = "\(value?["username"] as! String)"
                let imageUrl: String!
                if (value?["image"] as! String).isEmpty {
                    imageUrl = "http://stackrage.com/gofeeds/images/user1.png"
                } else {
                    imageUrl = "http://stackrage.com/gofeeds/images/\(value?["image"] as! String)"
                }
                self.userName.text = myName
                self.rankTextFld.text = rank
                self.currentPortTxtFld.text = current_port
                self.desiredTextFld.text = desire_port
                self.agencyTextFld.text = agency
                self.officeTextfld.text = office
                self.userImage.sd_setImage(with: URL(string: imageUrl), completed: nil)
            } else {
                let okAction: AlertButtonWithAction = (.ok, nil)
                self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
            }
            Utility.hideActivityIndicator()
        }
    }
    
    @IBAction func onClickProfileImageBtn(_ sender: UIButton) {
        if imagePicker == nil {
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
        }
        
        let sheet = UIAlertController(title: "Upload Photo", message: "Select", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Take photo from camera", style: .default, handler: {(action) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .camera
                self.imagePicker.cameraCaptureMode = .photo
                self.imagePicker.modalPresentationStyle = .fullScreen
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                DispatchQueue.main.async {
                    let okAction: AlertButtonWithAction = (.ok, nil)
                    self.showAlertWith(message: .custom("Sorry, this device has no camera")!, actions: okAction)
                }
            }
        })
        
        let library = UIAlertAction(title: "Choose Image from library", style: .default, handler: { (action) in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            self.imagePicker.modalPresentationStyle = .fullScreen
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        sheet.addAction(camera)
        sheet.addAction(library)
        sheet.addAction(cancel)
        
        present(sheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let chosenImage = info[.editedImage] as? UIImage {
            self.imageToUpload = chosenImage
            self.userImage.image = self.imageToUpload
            self.userImage.contentMode = .scaleAspectFit
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickRankBtn(_ sender: UIButton) {
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
    
    @IBAction func onClickAgencyBtn(_ sender: UIButton) {
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
    
    @IBAction func onClickOfficeBtn(_ sender: UIButton) {
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
    
    @IBAction func onClickPortBtn(_ sender: UIButton) {
        let port : UIButton = sender
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
    
    @IBAction func onClickSaveBtn(_ sender: UIButton) {
        let rank = rankTextFld.text!
        let office = officeTextfld.text!
        let agency = agencyTextFld.text!
        let currentPort = currentPortTxtFld.text!
        let desiredPort = desiredTextFld.text!
        
        Utility.showActivityIndicator()
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let data = self.imageToUpload?.pngData() {
                    multipartFormData.append(data, withName: "image", fileName: "image\(LoginSession.getValueOf(key: SessionKeys.showId)).png", mimeType: "png")
                }
                
                multipartFormData.append("hello".data(using: .utf8, allowLossyConversion: false)!, withName: "firstname")
                multipartFormData.append("\(rank)".data(using: .utf8, allowLossyConversion: false)!, withName: "rank")
                multipartFormData.append("\(office)".data(using: .utf8, allowLossyConversion: false)!, withName: "office")
                multipartFormData.append("\(agency)".data(using: .utf8, allowLossyConversion: false)!, withName: "agency")
                multipartFormData.append("\(currentPort)".data(using: .utf8, allowLossyConversion: false)!, withName: "current_port")
                multipartFormData.append("\(desiredPort)".data(using: .utf8, allowLossyConversion: false)!, withName: "desire_port")
                multipartFormData.append(LoginSession.getValueOf(key: SessionKeys.showId).data(using: .utf8, allowLossyConversion: false)!, withName: "id")
            }, to: UpdateProfileUrl) { (encodingResult) in
                
                DispatchQueue.main.async {
                    
                    
                    print("Encoding Result >>>>", encodingResult)
                    
                    Utility.hideActivityIndicator()
                    
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            print(response.result.value ?? [:])
                            let responseValue = response.result.value as! [String:Any]?
                            
                            LoginSession.saveValue(value: self.rankTextFld.text!, key: SessionKeys.rank)
                            LoginSession.saveValue(value: self.agencyTextFld.text!, key: SessionKeys.agency)
                            LoginSession.saveValue(value: self.officeTextfld.text!, key: SessionKeys.office)
                            LoginSession.saveValue(value: self.currentPortTxtFld.text!, key: SessionKeys.currentPort)
                            LoginSession.saveValue(value: self.desiredTextFld.text!, key: SessionKeys.desiredPort)
                            
                            if(responseValue != nil) {
                                
                                let okAction: AlertButtonWithAction = (.ok, nil)
                                self.showAlertWith(message: .custom("\(responseValue?["message"] ?? "")")!, actions: okAction)
                                
                                let userDataArr:[[String: Any]] = responseValue?["userdata"] as? [[String : Any]] ?? []
                                let userData: [String : Any] = userDataArr[0] as? [String : Any] ?? [:]
                                LoginSession.saveValue(value: userData["image"] as! String, key: SessionKeys.image)
                            }
                        }
                    case .failure(let encodingError):
                        print(encodingError)
                    }
                }
            }
        
//        Alamofire.request(url,  method: .post, parameters: ["id": myID, "firstname": "", "lastname": "", "image": "", "rank": rankTextFld.text!, "agency": agencyTextFld.text!, "current_port": currentPortTxtFld.text!, "desire_port": desiredTextFld.text!, "office": officeTextfld.text!]).responseJSON { response in
//            let value = response.result.value as! [String:Any]?
//            let BoolValue = value?["success"] as! Bool
////            if(BoolValue == true) {
////
////            }else {
//                let okAction: AlertButtonWithAction = (.ok, nil)
//                self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
////            }
//        }
    }
    
    @IBAction func logoutBtnAvction(_ sender: Any) {
        let alert = UIAlertController(title: "",
          message: "Are you sure you want to logout?",
          preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            LoginSession.destroy()
//        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
//        self.navigationController?.isNavigationBarHidden = true
            if let rootNavigationController = UIApplication.shared.windows.first?.rootViewController as? UINavigationController {
                rootNavigationController.popToRootViewController(animated: true)
            }
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
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
    
    @objc func updateDesiredPort(notification: Notification){
//        let desiredPortVC = notification.object as! multiSelectionPopUpVC
        
        //for port in seletedDesiredPorts
        
        if portType == "current"{
            self.currentPortTxtFld.text = selectedCurrentPort
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
        
        self.desiredTextFld.text = ports
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
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
            rankTextFld.text = Ranks[row]
//            removeFromSuper()
        case agencyPicker:
            agencyTextFld.text = Agencies[row]
//            removeFromSuper()
        case officePicker:
            officeTextfld.text = Officies[row]
//            removeFromSuper()
        default:
            print("Invalid Request")
        }
    }
    
}
