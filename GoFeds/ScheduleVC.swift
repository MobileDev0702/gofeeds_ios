//
//  ScheduleVC.swift
//  GoFeds
//
//  Created by Novos on 21/04/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import FSCalendar

class ScheduleVC: UIViewController, FSCalendarDataSource, FSCalendarDelegate {
    
    //MARK:- IBOutlets
    @IBOutlet weak var myCalenderView: FSCalendar!
    
    //MARK:- Variables
    
    //MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        myCalenderView.dataSource = self
        myCalenderView.delegate = self
        myCalenderView.firstWeekday = 1
        myCalenderView.appearance.titleWeekendColor = #colorLiteral(red: 0.06893683225, green: 0.2285976112, blue: 0.6367123723, alpha: 1)
        myCalenderView.allowsMultipleSelection = true
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK:- Button Actions
    @IBAction func settingBtn(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SettingVC") as? SettingVC
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date \(self.dateFormatter.string(from: date))")
        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
        print("selected dates is \(selectedDates)")
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditCalendarVC") as? EditCalendarVC
        vc?.myText = "\(self.dateFormatter.string(from: date))"
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(vc!, animated: true)
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
}
