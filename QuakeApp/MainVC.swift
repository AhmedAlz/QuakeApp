//
//  MainVC.swift
//  QuakeApp
//
//  Created by Ahmed on 2/9/18.
//  Copyright © 2018 Ahmed. All rights reserved.
//

import UIKit
import CoreMotion
import Kronos
import Alamofire


class MainVC: UIViewController {
    
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var settings: UILabel!
    @IBOutlet weak var readings: UILabel!
    
    
    let manager = CMMotionManager()
    
    let userDefaults = UserDefaults.standard
    
    
    var threshold : Double = 0.6
    var duration : Double = 10
    var counter : Double = 1
    var startRecording = false
    let samplingRate : Double = 1/200.0
    let url = "http://ec2-54-153-50-104.us-west-1.compute.amazonaws.com/api"
    
    
    
    // get the address
    
    var emailAddress = ""
    var buildingNumber = ""
    var streetName = ""
    var zipCode = ""
    var floor = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        threshold = userDefaults.double(forKey: "threshold")
        duration = userDefaults.double(forKey: "duration")
        
        emailAddress = userDefaults.string(forKey: "email")!
        buildingNumber = userDefaults.string(forKey: "buildingNumber")!
        streetName = userDefaults.string(forKey: "streetName")!
        zipCode = userDefaults.string(forKey: "zipCode")!
        floor = userDefaults.integer(forKey: "floor")
        
        // manager.stopAccelerometerUpdates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        
        self.startupdate()
        
    }
    
    func startupdate()  {
        
        var x = [Any]()
        var y = [Any]()
        var z = [Any]()
        var t = [Any]()
        
        var now = Clock.now?.timeIntervalSince1970 ?? 0.0
        if manager.isAccelerometerAvailable {
            manager.accelerometerUpdateInterval = samplingRate
            manager.startAccelerometerUpdates(to: OperationQueue.main) {
                [weak self] data, error in
                now = now + self!.samplingRate
                
                self!.readings.text = "x: \(data!.acceleration.x * 9.80665)\ny: \(data!.acceleration.y * 9.80665) \nz: \(data!.acceleration.z * 9.80665) \n time: \(now)"
                
                if abs(data!.acceleration.z * 9.80665) > 8 && sqrt(pow(data!.acceleration.x * 9.80665,2) + pow(data!.acceleration.y * 9.80665,2)) > Double((self?.threshold)!)  {
                    self?.startRecording = true
                }
                
                if self!.startRecording {
                    if self!.counter == 1 {
                        now = Clock.now?.timeIntervalSince1970 ?? 0.0
                    } else if self!.counter ==  self!.duration * (1/self!.samplingRate ) - 1.0 {
                        now = Clock.now?.timeIntervalSince1970 ?? 0.0
                    }
                    
                    self!.counter = self!.counter + 1
                    if self!.counter < self!.duration * (1/self!.samplingRate ) {
                        x.append(data!.acceleration.x * 9.80665)
                        y.append(data!.acceleration.y * 9.80665)
                        z.append(data!.acceleration.z * 9.80665)
                        t.append(now)
                        
                    } else{
                        let parameters: Parameters = ["deviceID": self!.emailAddress , "buildingNumber" : self!.buildingNumber ,"streetName" : self!.streetName ,"zipCode" : self!.zipCode ,"floor" : self!.floor, "x": x , "y": y , "z": z, "rtime": t]
                        
                        Alamofire.request(self!.url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                            .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                                print("Progress: \(progress.fractionCompleted)")
                                print(now)
                        }
                        
                        self!.counter  = 1
                        x = []
                        y = []
                        z = []
                        t = []
                        self!.startRecording = false
                    }
                }
                
                
                
            }
        }
        
    }
    
    
    
    
}
