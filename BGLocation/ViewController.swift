//
//  ViewController.swift
//  BGLocation
//
//  Created by dhaval nagar on 5/13/16.
//  Copyright © 2016 dhaval nagar. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate{

    let locationManager = CLLocationManager()
    var lastLocation: CLLocation?;
    var debug: Bool = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startService()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
        Start the Location Update Service
    */
    func startService(){
        self.locationManager.delegate = self
        
        // Accuracty is set to medium and will be adjusted later
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        self.locationManager.requestAlwaysAuthorization();
        
        // Significant Changes will be used later on for passive updates
        self.locationManager.startMonitoringSignificantLocationChanges();
        
        // Notifications for debuging purpose
        if debug {
            let notificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        }
    }
    
    func stopService(){
        self.locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Distance Filter Login Here
        
        if debug {
            showNotification(manager.location!.coordinate);
        }
    }
    
    func showNotification(let coordinate : CLLocationCoordinate2D){
        print("Location updated: \(coordinate.latitude), \(coordinate.longitude)")
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 1)
        
        if lastLocation != nil {
            let currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let meters:CLLocationDistance = lastLocation!.distanceFromLocation(currentLocation)
            
            notification.alertBody = "Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude), Disnance: \(meters)"
        }else{
            notification.alertBody = "Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude), Disnance: 0"
        }
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        lastLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

