//
//  CurrentUserInfo.swift
//  PlutoGo
//
//  Created by Tarun Sachdeva on 01/06/18.
//  Copyright © 2018 Tsss. All rights reserved.
//

import Foundation

struct CurrentUserInfo {
    
    static var showID : String!
    static var currentPort : String!
    static var desiredPort : String!
    static var rank : String!
    static var agency : String!
    static var firstname : String!
    static var lastname : String!
    static var email : String!
    
    init(dict : NSDictionary)  {
        //CurrentUserInfo.userInfo = dict
        let data = dict
        
        print(data)
        let ID = data["id"]
        print(ID as Any)
        //let id = Int(ID)//data["id"] as! Int
        CurrentUserInfo.showID = String("\(ID)")
        
        if (data["current_port"] as? NSNull) == nil {
            CurrentUserInfo.currentPort = (data["current_port"].map { $0 as? String } ?? "")!
        }
        else {
            CurrentUserInfo.currentPort = ""
        }
        
        if ((data["desire_port"] as? NSNull) == nil){
            CurrentUserInfo.desiredPort = (data["desire_port"].map { $0 as? String } ?? "")!
        }
        else {
            CurrentUserInfo.desiredPort = ""
        }
        
        if (data["rank"] as? NSNull) == nil {
            CurrentUserInfo.rank = (data["rank"].map { $0 as? String } ?? "")!
        }
        else {
            CurrentUserInfo.rank = ""
        }
        
        if (data["agency"] as? NSNull) == nil {
            CurrentUserInfo.agency = (data["agency"].map { $0 as? String } ?? "")!
        }
        else {
            CurrentUserInfo.agency = ""
        }
        
        
        if (data["lastname"] as? NSNull) == nil {
            CurrentUserInfo.lastname = (data["lastname"].map { $0 as? String } ?? "")!
        }
        else {
            CurrentUserInfo.lastname = ""
        }
        
        if (data["email"] as? NSNull) == nil {
            CurrentUserInfo.email = (data["email"].map { $0 as? String } ?? "")!
        }
        else {
            CurrentUserInfo.email = ""
        }
        
        if (data["firstname"] as? NSNull) == nil {
            CurrentUserInfo.firstname = (data["firstname"].map { $0 as? String } ?? "")!
        }
        else {
            CurrentUserInfo.firstname = ""
        }
    }
}
