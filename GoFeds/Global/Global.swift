//
//  Global.swift
//  GoFeds
//

import Foundation
import UIKit
import Foundation
import NVActivityIndicatorView
import SystemConfiguration

class Utility: NSObject {
    
    struct Tag{
        static let indicatorTag = 100
        static let blurviewTag = 101
    }
    
    static func showActivityIndicator(){
        NVActivityIndicatorView.DEFAULT_COLOR = UIColor(red: 200/255, green: 47/255, blue: 120/255, alpha: 1.0)
        let navigationControler = UINavigationController()
        let navigationBarHeight: CGFloat = navigationControler.navigationBar.frame.height
        let window = UIApplication.shared.keyWindow
        if window == nil {
            return
        }
        print(window!.frame.origin.x)
        let blurView = UIView(frame: CGRect(x: window!.frame.origin.x, y: window!.frame.origin.y+navigationBarHeight, width: window!.frame.width, height: window!.frame.height-navigationBarHeight*2))
            window!.addSubview(blurView);
            blurView.backgroundColor = UIColor.clear
        let indicatorView = NVActivityIndicatorView(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
        indicatorView.center = CGPoint(x: (window!.frame.width)/2, y: (window!.frame.height)/2)//blurView.center
            indicatorView.backgroundColor = UIColor.clear
            indicatorView.startAnimating()
        window!.addSubview(indicatorView)
            indicatorView.tag = Tag.indicatorTag
        blurView.tag = Tag.blurviewTag
    }
    
    static func hideActivityIndicator(){
        let window = UIApplication.shared.keyWindow!
        if let view = window.viewWithTag(Tag.indicatorTag){
            view.removeFromSuperview()
        }
        if let view = window.viewWithTag(Tag.blurviewTag){
            view.removeFromSuperview()
        }
    }
    
}

extension UIView {
    func bottomMaskViewShadow(){
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 1
    }
    
    func addShodow(){
        let shadowSize : CGFloat = 1.0
        let shadowPath3 = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                    y: -shadowSize / 2,
                                                    width: self.layer.frame.size.width,
                                                    height: self.layer.frame.size.height))
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 1
        self.layer.shadowPath = shadowPath3.cgPath
        self.layer.cornerRadius = 5
    }
    
    func addBottomShadow(){
        self.layer.masksToBounds = false
        self.layer.shadowOpacity = 0.1
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0 , height:2)
    }
}

extension UIViewController{
    //MARK:- Functions Declaration
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            if results.count == 0 {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        return  returnValue
    }
}

//MARK:- User Defaults
struct LoginSession {
    
    static let defaults = UserDefaults.standard
    static let currentUserFToken = LoginSession.getValueOf(key: SessionKeys.fToken)
    static let currentUserId = LoginSession.getValueOf(key: SessionKeys.showId)
    
    static func start(ftoken: String,userName:String,email:String,showId:String,desiredPort:String,rank:String,agency:String,currentPort:String,office: String){
        defaults.set(showId, forKey: SessionKeys.showId)
        defaults.set(userName, forKey: SessionKeys.userName)
        defaults.set(email, forKey: SessionKeys.email)
        defaults.set(desiredPort, forKey: SessionKeys.desiredPort)
        defaults.set(rank, forKey: SessionKeys.rank)
        defaults.set(agency, forKey: SessionKeys.agency)
        defaults.set(currentPort, forKey: SessionKeys.currentPort)
        defaults.set(ftoken, forKey: SessionKeys.fToken)
        defaults.set(office, forKey: SessionKeys.office)
    }
    static func destroy(){
        defaults.removeObject(forKey: SessionKeys.userName)
        defaults.removeObject(forKey: SessionKeys.showId)
        defaults.removeObject(forKey: SessionKeys.email)
        defaults.removeObject(forKey: SessionKeys.fToken)
        defaults.removeObject(forKey: SessionKeys.desiredPort)
        defaults.removeObject(forKey: SessionKeys.rank)
        defaults.removeObject(forKey: SessionKeys.agency)
        defaults.removeObject(forKey: SessionKeys.currentPort)
        defaults.removeObject(forKey: SessionKeys.office)
        
    }
    static func isActive()-> Bool{
        if defaults.value(forKey: SessionKeys.showId) != nil {
            return true
        }
        return false
    }
    static func getValueOf(key:String) -> String {
        return (defaults.value(forKey: key) as? String)!
    }
}
