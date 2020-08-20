//
//  ConnectionVC.swift
//  GoFeds
//
//  Created by Novos on 21/04/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ConnectionVC: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var connectTable: UITableView!
    @IBOutlet weak var possibleVW: UIView!
    @IBOutlet weak var exactVW: UIView!
    @IBOutlet weak var exactMAtchBtn: UIButton!
    @IBOutlet weak var possibleMatchBtn: UIButton!
    
    //MARK:- Variables
    var exactUserArray = NSArray()
    var possibleUserArray = NSArray()
    var isExactSelected : Bool = true
    var indexP = -1
    
    
    //MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isExactSelected = true
        
        possibleVW.isHidden = true
        possibleMatchBtn.setTitleColor(UIColor.lightGray, for: .normal)
        getExactMatchesList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func getExactMatchesList() {
        
        Utility.showActivityIndicator()
         
        let id  = LoginSession.getValueOf(key: SessionKeys.showId)
        
        let userID = id//UserDefaults.standard.value(forKey: "showID")
        var url = PossibleMatchUrl//ViewUsersByAgencyUrl
        
        if isExactSelected {
            url = ExactMatchUrl
        }
        print(url)
        Alamofire.request(url,  method: .post, parameters: ["user_id": userID]).responseJSON { response in
            
            let value = response.result.value as! [String:Any]?
            if value == nil {
                Utility.hideActivityIndicator()
                let okAction: AlertButtonWithAction = (.ok, nil)
                self.showAlertWith(message: .custom("No Match Found)")!, actions: okAction)
                return
            }
                           
                print(value)
                           
                let BoolValue = value?["success"] as! Bool
                Utility.hideActivityIndicator()
                    if(BoolValue == true) {
            
                        if self.isExactSelected {
                            self.exactUserArray = value?["data"] as! NSArray
                        }
                        else{
                            self.possibleUserArray = value?["data"] as! NSArray
                        }
                        self.connectTable.reloadData()
            }
            
                    else {
                       
                            Utility.hideActivityIndicator()
                            let okAction: AlertButtonWithAction = (.ok, nil)
                            self.showAlertWith(message: .custom("No Match Found)")!, actions: okAction)
                            return
            }
            }
            /*
              let BoolValue = value?["success"] as! Bool
              print(value!)
              if(BoolValue == true) {
                self.exactUserArray = value!["data"] as! NSArray
                  Utility.hideActivityIndicator()
                  self.dismiss(animated: true, completion: nil)
                self.connectTable.reloadData()
              }else {
                  Utility.hideActivityIndicator()
                  let okAction: AlertButtonWithAction = (.ok, nil)
                  self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
              }
            */
          }
    
    //MARK:- Button Actions
    @IBAction func exactMatchBtn(_ sender: Any) {
        isExactSelected = true
        getExactMatchesList()
        possibleVW.isHidden = true
        exactVW.isHidden = false
        possibleMatchBtn.setTitleColor(UIColor.lightGray, for: .normal)
        exactMAtchBtn.setTitleColor(UIColor.white, for: .normal)
    }
    
    @IBAction func possibleMatchBtn(_ sender: Any) {
        isExactSelected = false
        getExactMatchesList()
        exactVW.isHidden = true
        possibleVW.isHidden = false
        exactMAtchBtn.setTitleColor(UIColor.lightGray, for: .normal)
        possibleMatchBtn.setTitleColor(UIColor.white, for: .normal)
    }
    
    @IBAction func chatBtn(_ sender: Any) {
//        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChatVC") as? ChatVC
//               self.navigationController?.isNavigationBarHidden = true
//               self.navigationController?.pushViewController(vc!, animated: true)
        self.performSegue(withIdentifier: "ConnectionToChatVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ConnectionToProfileVC" {
            if let destinationVC = segue.destination as? MyProfileVC {
                if isExactSelected {
                    let data = exactUserArray.object(at: indexP) as! NSDictionary
                    destinationVC.userData = data
                } else {
                    let data = possibleUserArray.object(at: indexP) as! NSDictionary
                    destinationVC.userData = data
                }
            }
        }
    }
    
}
//MARK:- TableView Delegates & DataSource
extension ConnectionVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isExactSelected {
            return exactUserArray.count
        }
        else {
            return possibleUserArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CommonTableViewCell
        if isExactSelected {
            let data = exactUserArray.object(at: indexPath.row) as! NSDictionary
            cell.connectUsername.text = (data["username"] as! String)
            cell.connectionPortName.text = (data["current_port"] as! String)
        }
        else {
            let data = possibleUserArray.object(at: indexPath.row) as! NSDictionary
            cell.connectUsername.text = (data["username"] as! String)
            cell.connectionPortName.text = (data["current_port"] as! String)
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backView.addShodow()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexP = indexPath.row
        self.performSegue(withIdentifier: "ConnectionToProfileVC", sender: nil)
    }
    
    
}
