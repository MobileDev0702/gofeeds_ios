//
//  EditCalendarVC.swift
//  GoFeds
//
//  Created by Novos on 29/04/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit

class EditCalendarVC: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textEventEdit: UITextField!
    @IBOutlet weak var saveBtn: GradientButton!
    
    //MARK:- Variables
    var myText : String?
    var myEventText:String?
    
    //MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.text = myText
        textEventEdit.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Button Actions
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        myEventText = "\(textEventEdit.text)"
        textEventEdit.isUserInteractionEnabled = false
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
