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
    let samplingRate : Double = 1/100.0
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
        
        self.address.text = " Email : \(userDefaults.string(forKey: "email")!) \n Building Number: \(userDefaults.string(forKey: "buildingNumber")!)\n Street Name: \(userDefaults.string(forKey: "streetName")!)\n Zip Code \(userDefaults.string(forKey: "zipCode")!)\n Floor \(userDefaults.integer(forKey: "floor"))"
        
        self.settings.text = " Threshould = \((threshold * 100.0).rounded()/100)  m/s^2 \n Duration = \((duration * 100.0).rounded()/100) seconds"
        
        
        self.startupdate()
        
    }
    
    func startupdate()  {
        
        var x = [Any]()
        var y = [Any]()
        var z = [Any]()
        var t = [Any]()
        var readings = [Any]()
        
//        var date = NSDate()
        var now  = NSDate().timeIntervalSince1970 ?? 0.0
        print(now)

//        var now = Clock.now?.timeIntervalSince1970 ?? 0.0
//        print(now)
        if manager.isAccelerometerAvailable {
            manager.accelerometerUpdateInterval = samplingRate
            manager.startAccelerometerUpdates(to: OperationQueue.main) {
                [weak self] data, error in
                now = now + self!.samplingRate
                
                self!.readings.text = "x: \((data!.acceleration.x * 9.80665 * 100.0).rounded()/100)\ny: \((data!.acceleration.y * 9.80665 * 100).rounded()/100.0) \nz: \((data!.acceleration.z * 9.80665 * 100.0).rounded()/100) \n time: \(now)"
                
                if abs(data!.acceleration.z * 9.80665) > 8.0 && sqrt(pow(data!.acceleration.x * 9.80665,2) + pow(data!.acceleration.y * 9.80665,2)) > Double((self?.threshold)!)  {
                    self?.startRecording = true
                }
                
                if self!.startRecording {
                    if self!.counter == 1 {
                        now = NSDate().timeIntervalSince1970
                        print(now)
                        print("start")
                    } else if self!.counter ==  (self!.duration * (1/self!.samplingRate )) - 2.0 {
                        now = NSDate().timeIntervalSince1970
                        print(now)
                        print("end")
                    }
                    
                    self!.counter = self!.counter + 1
                    if self!.counter < self!.duration * (1/self!.samplingRate ) {
                        x.append(data!.acceleration.x * 9.80665)
                        y.append(data!.acceleration.y * 9.80665)
                        z.append(data!.acceleration.z * 9.80665)
                        t.append(now)
                        
                    } else{
                        let readings = [  "x": x , "y": y , "z": z, "rtime": t]
                        let parameters: Parameters = ["deviceID": self!.emailAddress , "buildingNumber" : self!.buildingNumber ,"streetName" : self!.streetName ,"zipCode" : self!.zipCode ,"floor" : self!.floor, "x": x , "y": y , "z": z, "rtime": t, "reading" : readings]
                        
                        Alamofire.request(self!.url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                            .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                                print("Progress: \(progress.fractionCompleted)")
                                print(now)
                                print("sent")
                                
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
