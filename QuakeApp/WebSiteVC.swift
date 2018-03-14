//
//  WebSiteVC.swift
//  QuakeApp
//
//  Created by Ahmed on 3/13/18.
//  Copyright © 2018 Ahmed. All rights reserved.
//
import UIKit
import WebKit
class WebSiteVC: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    
    

    
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        let button:UIButton = UIButton(frame: CGRect(x: 25, y: 25, width: 50, height: 25))
        button.backgroundColor = UIColor.gray
        button.setTitle("Back", for: UIControlState.normal)
        button.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
        webView.addSubview(button)
        

        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string: "http://ec2-54-153-50-104.us-west-1.compute.amazonaws.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    @objc func buttonClicked() {
        self.dismiss(animated: true) {
            
        }
        print("Button Clicked")
    }
}
