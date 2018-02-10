//
//  ViewController.swift
//  QuakeApp
//
//  Created by Ahmed on 2/8/18.
//  Copyright © 2018 Ahmed. All rights reserved.
//


import UIKit


class Settings: UIViewController {
    
    let userDefaults = UserDefaults.standard

    
    @IBOutlet weak var thresholdInput: UITextField!
    
    @IBOutlet weak var DurationInput: UITextField!
    
    @IBOutlet weak var button: UIButton!
    
    
    @IBAction func apply(_ sender: UIButton) {

        // settings
        userDefaults.set(Float(thresholdInput.text!), forKey: "threshold")
        userDefaults.set(Float(DurationInput.text!), forKey: "duration")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "mainID")
        self.present(vc, animated: true)
        
        


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        button.layer.cornerRadius = 5
    
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    
    
}

