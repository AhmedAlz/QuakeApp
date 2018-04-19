//
//  Settings.swift
//  QuakeApp
//
//  Created by Ahmed on 2/9/18.
//  Copyright © 2018 Ahmed. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {

    @IBOutlet weak var Address: UILabel!
    
    let userDefaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = userDefaults.string(forKey: "email") {
        
        } else {
            //to check if user put the address
            userDefaults.set("no", forKey: "isAddressSet")
            // the address
             userDefaults.set("alzughaa@uci.edu", forKey: "email")
             userDefaults.set("5200", forKey: "buildingNumber")
             userDefaults.set("engineeringhall", forKey: "streetName")
             userDefaults.set("92697", forKey: "zipCode")
             userDefaults.set(4, forKey: "floor")
            // settings
             userDefaults.set(0.6, forKey: "threshold")
             userDefaults.set(10.0, forKey: "duration")
    }
        Address.text = " Email : \(userDefaults.string(forKey: "email")!) \n Building Number: \(userDefaults.string(forKey: "buildingNumber")!)\n Street Name: \(userDefaults.string(forKey: "streetName")!)\n Zip Code: \(userDefaults.string(forKey: "zipCode")!)\n Floor: \(userDefaults.integer(forKey: "floor"))"
    
     //  print(userDefaults.string(forKey: "test"))
       
    }


}
