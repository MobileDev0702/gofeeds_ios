//
//  NewsDetailsVC.swift
//  GoFeds
//
//  Created by Inderveer Singh on 31/05/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import WebKit

var url = ""
class NewsDetailsVC: UIViewController, WKNavigationDelegate,WKUIDelegate{

    
    @IBOutlet weak var webView: WKWebView!
    
    let Activity : UIActivityIndicatorView = UIActivityIndicatorView()
    let activityIndicatorContainerView : UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       let webUrl = URL(string: url)
       let request = URLRequest(url: webUrl!)
        webView.load(request)
        
        // add activity
        
        self.Activity.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.Activity.center = webView.center
        self.webView.addSubview(self.Activity)
        self.Activity.startAnimating()
        self.webView.navigationDelegate = self
        self.Activity.hidesWhenStopped = true
        self.webView.uiDelegate = self
    }
    
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Activity.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Activity.stopAnimating()
    }

}
