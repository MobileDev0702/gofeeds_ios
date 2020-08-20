//
//  SettingVC.swift
//  GoFeds
//
//  Created by Novos on 20/04/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit

class SettingVC: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var firstVW: UIView!
    @IBOutlet weak var secondVW: UIView!
    
    //MARK:- Variables
    let secondarr = ["Help Center", "Safety Center"]
    let firstArr = ["Terms and Use", "Privacy Policy", "Copyright Policy"]
    
    //MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        firstVW.addBottomShadow()
        secondVW.addBottomShadow()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Button Actions
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func helpCenterBtn(_ sender: Any) {
        
    }
    
    @IBAction func safetyCenterBtn(_ sender: Any) {
        
        
    }
    
    @IBAction func termsAndUseBtn(_ sender: Any) {
        
    }
    
    @IBAction func privacyPolicy(_ sender: Any) {
        
    }
    
    @IBAction func copyrightPolicyBtn(_ sender: Any) {
        
    }
    
    
    @IBAction func logOutBtn(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
}
