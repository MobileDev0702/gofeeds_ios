//
//  LogoutAlertVC.swift
//  POS-Native
//
//  Created by intersoft-admin on 08/03/18.
//  Copyright © 2018 intersoft-kansal. All rights reserved.
//

import Foundation
import UIKit
class LogoutAlertVC: UIViewController
{
    @IBOutlet var mainVw: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
          self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    override func viewDidLayoutSubviews()
    {
        mainVw.backgroundColor =  #colorLiteral(red: 0.1333333333, green: 0.137254902, blue: 0.1411764706, alpha: 0.802547089)
        //        return UIColor.init(red: 34/255, green: 35/255, blue: 36/255, alpha:0.8)
    }
}
