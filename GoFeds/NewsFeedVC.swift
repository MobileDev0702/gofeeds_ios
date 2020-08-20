//
//  NewsFeedVC.swift
//  GoFeds
//
//  Created by Novos on 22/04/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class NewsFeedVC: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var newsFeed: UILabel!
    @IBOutlet weak var newsFeedBtn: UIButton!
    @IBOutlet weak var newsFeedImage: UIImageView!
    @IBOutlet weak var userfulLinkBtn: UIButton!
    @IBOutlet weak var usefulLink: UILabel!
    @IBOutlet weak var usefulLinkImage: UIImageView!
    @IBOutlet weak var tblNewsFeed: UITableView!
    
    //MARK:- Variables
    var listArray = NSArray()
    
    //MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
       // view1.layer.cornerRadius = 25
       // view2.layer.cornerRadius = 25
      //  usefulLink.tintColor = UIColor.lightGray
      //  newsFeed.tintColor = UIColor.white
      //  newsFeedImage.image = UIImage(named: "NEWS FEEDG")
      //  usefulLinkImage.image = UIImage(named: "USEFUL LINKS")
        
        getExactMatchesList()
        // Do any additional setup after loading the view.
    }
    
    
    func getExactMatchesList() {
          Utility.showActivityIndicator()
         
        let userID = UserDefaults.standard.value(forKey: SessionKeys.showId)
        let url = "http://newsapi.org/v2/top-headlines?country=us&apiKey=ebbbb3f623174e94a6e4db85208fba55"
        
        Alamofire.request(url,  method: .get, parameters: nil).responseJSON { response in
              let value = response.result.value as! [String:Any]?
             // let BoolValue = value?["success"] as! Bool
              
            print(value)
            self.listArray = value!["articles"] as! NSArray
            print(self.listArray)
            Utility.hideActivityIndicator()
            self.tblNewsFeed.reloadData()
//              if(BoolValue == true) {
//                  Utility.hideActivityIndicator()
//                  self.dismiss(animated: true, completion: nil)
//              }else {
//                  Utility.hideActivityIndicator()
//                  let okAction: AlertButtonWithAction = (.ok, nil)
//                  self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
//              }
          }
    }
    
    //MARK:- Button Actions
    @IBAction func newsFeedBtn(_ sender: Any) {
        usefulLink.tintColor = UIColor.lightGray
        newsFeed.tintColor = UIColor.white
        newsFeedImage.image = UIImage(named: "NEWS FEEDG")
        usefulLinkImage.image = UIImage(named: "USEFUL LINKS")
    }
    
    @IBAction func usefulLinkBtn(_ sender: Any) {
        usefulLink.tintColor = UIColor.white
        newsFeed.tintColor = UIColor.lightGray
        newsFeedImage.image = UIImage(named: "NEWS FEED")
        usefulLinkImage.image = UIImage(named: "USEFUL LINKSGR")
    }
    
    @IBAction func chatBtn(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChatVC") as? ChatVC
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}
//MARK:- TableView Delegates & DataSource
extension NewsFeedVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CommonTableViewCell
        cell.NewsVW.bottomMaskViewShadow()
        cell.NewsVW.layer.cornerRadius = 6.0
        
        let data = listArray.object(at: indexPath.row) as! NSDictionary
        cell.newsImage.layer.cornerRadius = 6.0
        
        let imgUrl = data["urlToImage"] as? String
        if imgUrl != nil {
            let url = imgUrl
            cell.newsImage.sd_setImage(with: URL(string: url!), completed: nil)
        }
        
        cell.newsHeadline.text = (data["title"] as! String)
        cell.newsPostTime.text = (data["publishedAt"] as! String)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewsDetailsVC") as? NewsDetailsVC
        let webUrls = self.listArray.value(forKey: "url") as! NSArray
        print("******\n/n\n/n**********")
        print(webUrls)
        url = webUrls[indexPath.row] as! String
        self.performSegue(withIdentifier: "FeedToDetailVC", sender: nil)
//        self.navigationController?.isNavigationBarHidden = true
//        self.navigationController?.pushViewController(vc!, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           // Get the new view controller using segue.destination.
           // Pass the selected object to the new view controller.
        self.navigationController?.isNavigationBarHidden = true
       }
}
