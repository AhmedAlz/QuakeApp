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
import CoreLocation


class MainVC: UIViewController , CLLocationManagerDelegate {
    
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var settings: UILabel!
    @IBOutlet weak var readings: UILabel!
    
    var locationManager = CLLocationManager()
    let manager = CMMotionManager()
    
    let userDefaults = UserDefaults.standard
    
    var threshold : Double = 0.6
    var duration : Double = 10
    var counter : Double = 1
    var startRecording = false
    var manualStart = false
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
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        threshold = userDefaults.double(forKey: "threshold")
        duration = userDefaults.double(forKey: "duration")
        
        emailAddress = userDefaults.string(forKey: "email")!
        buildingNumber = userDefaults.string(forKey: "buildingNumber")!
        streetName = userDefaults.string(forKey: "streetName")!
        zipCode = userDefaults.string(forKey: "zipCode")!
        floor = userDefaults.integer(forKey: "floor")
        
        // manager.stopAccelerometerUpdates()
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locValue:CLLocationCoordinate2D = manager.location?.coordinate {
        
            print("\(locValue.latitude)  \(locValue.longitude)")
            
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.address.text = " Email : \(userDefaults.string(forKey: "email")!) \n Building Number: \(userDefaults.string(forKey: "buildingNumber")!)\n Street Name: \(userDefaults.string(forKey: "streetName")!)\n Zip Code: \(userDefaults.string(forKey: "zipCode")!)\n Floor: \(userDefaults.integer(forKey: "floor"))"
        
        self.settings.text = " Threshould = \((threshold * 100.0).rounded()/100)  m/s^2 \n Duration = \((duration * 100.0).rounded()/100) seconds"
        
        
        Clock.sync { date, offset in
            print(date?.timeIntervalSince1970 ?? 0.0)
            self.startupdate()
        }
        
        
    }
    
    
    func startupdate()  {
        
        var x = [Double]()
        var y = [Double]()
        var z = [Double]()
        var t = [Double]()
        var readings = [Double]()
        
        
        //var now  = NSDate().timeIntervalSince1970 ?? 0.0
        //print(now)
        
        var now = Clock.now?.timeIntervalSince1970 ?? 0.0
        print(now)
        if manager.isAccelerometerAvailable {
            manager.accelerometerUpdateInterval = samplingRate
            manager.startAccelerometerUpdates(to: OperationQueue.main) {
                [weak self] data, error in
                //now = now + self!.samplingRate
                
                self!.readings.text = "x: \((data!.acceleration.x * 9.80665 * 100.0).rounded()/100)\ny: \((data!.acceleration.y * 9.80665 * 100).rounded()/100.0) \nz: \((data!.acceleration.z * 9.80665 * 100.0).rounded()/100) \n time: \(Clock.now?.timeIntervalSince1970 ?? 0.0)"
                
                if (abs(data!.acceleration.z * 9.80665) > 8.0 && sqrt(pow(data!.acceleration.x * 9.80665,2) + pow(data!.acceleration.y * 9.80665,2)) > Double((self!.threshold)) && self!.counter == 1) || (self!.manualStart == true && self!.counter == 1) {
                    self?.startRecording = true
                    print("start")
                    print(Clock.now?.timeIntervalSince1970 ?? 0.0)
                }
                
                if self!.startRecording {
                    self!.manualStart = false
                    
                    //                    if self!.counter == 1 {
                    //                        //now = NSDate().timeIntervalSince1970
                    //                        print(Clock.now?.timeIntervalSince1970 ?? 0.0)
                    //                        print("start")
                    //                    } else if self!.counter ==  (self!.duration * (1/self!.samplingRate )) - 2.0 {
                    //                        //now = NSDate().timeIntervalSince1970
                    //                        print(Clock.now?.timeIntervalSince1970 ?? 0.0)
                    //                        print("end")
                    //                    }
                    
                    self!.counter = self!.counter + 1
                    if self!.counter < self!.duration * (1/self!.samplingRate ) {
                        x.append(data!.acceleration.x * 9.80665)
                        y.append(data!.acceleration.y * 9.80665)
                        z.append(data!.acceleration.z * 9.80665)
                        t.append(Clock.now?.timeIntervalSince1970 ?? 0.0)
                        
                    } else if self!.counter == self!.duration * (1/self!.samplingRate )  {
                        print(Clock.now?.timeIntervalSince1970 ?? 0.0)
                        print("end")
                        let readings = [  "x": x , "y": y , "z": z, "rtime": t]
                        let parameters: Parameters = ["deviceID": self!.emailAddress , "buildingNumber" : self!.buildingNumber ,"streetName" : self!.streetName ,"zipCode" : self!.zipCode ,"floor" : self!.floor, "x": x , "y": y , "z": z, "rtime": t, "reading" : readings]
                        // add an if statment to save the data in the device and try to send later if there is now internet connection at the time detection
                        Alamofire.request(self!.url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                            .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                                print("Progress: \(progress.fractionCompleted)")
                                print(Clock.now?.timeIntervalSince1970 ?? 0.0)
                                print("sent")
                                print(self!.duration)
                                print("duration")
                                print(self!.threshold)
                                print("threshold")
                                
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
    
    @IBAction func manualStartButton(_ sender: Any) {
        self.manualStart = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        manager.stopAccelerometerUpdates()
    }
    
}
