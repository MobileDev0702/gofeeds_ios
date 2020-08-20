//
//  AlertGlobal.swift
//  Rokk
//
//  Created by intersoft-admin on 08/03/18.
//  Copyright © 2018 intersoft-parminder. All rights reserved.
//

import Foundation
import UIKit

typealias AlertHandler = () -> ()
typealias AlertHandlerN = (Bool) -> ()

class CustomAlert: NSObject, UITextFieldDelegate
{
    private var objTwoOPtionsAlertVC: LogoutAlertVC!
    private var alerthandler: AlertHandlerN!
    
    static let sharedInstance = CustomAlert()
    
    //MARK: - Custom Alert Messages SetUp
    func showTwoOptionsAlertWithHandlerAndTitle(_ title:String, _ msg: String, _ firstBtnTitle: String, _ secondBtnTitle: String,  vc: UIViewController?,_ alertHandler: @escaping AlertHandlerN)
    {
        vc?.view.endEditing(true)
        
        if(objTwoOPtionsAlertVC != nil)
        {
            objTwoOPtionsAlertVC.view.removeFromSuperview()
            objTwoOPtionsAlertVC = nil
        }
        
        let storyboard = UIStoryboard.init(name: "POPUps", bundle: nil)
        objTwoOPtionsAlertVC = storyboard.instantiateViewController(withIdentifier: "LogoutAlertVC") as? LogoutAlertVC
        AppDelegate.sharedDelegate().window?.addSubview(objTwoOPtionsAlertVC.view)
        
        self.alerthandler = alertHandler
        objTwoOPtionsAlertVC.titleLbl.text = title
        objTwoOPtionsAlertVC.messageLbl.text = msg
        
        objTwoOPtionsAlertVC.okBtn.setTitle(firstBtnTitle, for: .normal)
        objTwoOPtionsAlertVC.cancelBtn.setTitle(secondBtnTitle, for: .normal)
        objTwoOPtionsAlertVC.okBtn.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        objTwoOPtionsAlertVC.cancelBtn.addTarget(self, action: #selector(cancelDismissAlert), for: .touchUpInside)
    }
    
    func showTwoOptionsAlertWithHandlerAndTitle(_ title:String, _ msg: String, _ firstBtnTitle: String, _ secondBtnTitle: String,  vc: UIViewController?,_ alertHandler: @escaping AlertHandler)
    {
        self.showTwoOptionsAlertWithHandlerAndTitle(title, msg, firstBtnTitle, secondBtnTitle, vc: vc) { (status) in
            
            if status
            {
                alertHandler()
            }
        }
    }
    
    //MARK: - UITextFieldDelegate
    @objc private func dismissAlert()
    {
        self.removeAlert(true)
    }
    
    private func removeAlert(_ status: Bool)
    {
        if(objTwoOPtionsAlertVC != nil)
        {
            objTwoOPtionsAlertVC.view.removeFromSuperview()
            objTwoOPtionsAlertVC = nil
            
            if(alerthandler != nil)
            {
                alerthandler(status)
            }
        }
    }
    
    @objc private func cancelDismissAlert()
    {
        self.removeAlert(false)
    }
    
    func removeAlert()
    {
        if(objTwoOPtionsAlertVC != nil)
        {
            objTwoOPtionsAlertVC.view.removeFromSuperview()
            objTwoOPtionsAlertVC = nil
        }
    }
}
