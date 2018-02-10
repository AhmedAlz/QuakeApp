//
//  UpdateAddress.swift
//  QuakeApp
//
//  Created by Ahmed on 2/9/18.
//  Copyright © 2018 Ahmed. All rights reserved.
//

import UIKit

class UpdateAddress: UIViewController {
    let userDefaults =  UserDefaults.standard
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var buildingNumber: UITextField!
    @IBOutlet weak var streetName: UITextField!
    @IBOutlet weak var zipCode: UITextField!
    @IBOutlet weak var floor: UITextField!
    
    override func viewDidLoad() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        super.viewDidLoad()

    }
    
    
    @objc func dismissKeyboard() {
            view.endEditing(true)
    }
    
    
    
    @IBAction func apply(_ sender: Any) {
        print("adress set")
        //to check if user put the address
        userDefaults.set("yes", forKey: "isAddressSet")
        // the address
        userDefaults.set(email.text!, forKey: "email")
        userDefaults.set(buildingNumber.text!, forKey: "buildingNumber")
        userDefaults.set(streetName.text!, forKey: "streetName")
        userDefaults.set(zipCode.text!, forKey: "zipCode")
        userDefaults.set(Int(floor.text!), forKey: "floor")
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "mainID")
        self.present(vc, animated: true)
        
    }
    


    
    
    
    



}
