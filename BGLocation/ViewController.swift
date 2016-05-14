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
    var lastLocation: CLLocation?
    
    var debug: Bool = true
    var timer: NSTimer?
    var isMoving: Bool = false
    
    // Time based filters to ignore updates outside of the range
    var timeFilterStart = 9
    var timeFilterStop = 18
    var timeFilterEnabled = false
    
    // Distance based filter to ignore updates inside of the distance
    var distanceFilter: Double = 500
    var distanceFilterEnabled = true
    
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
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
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
    
    // Stop Significant Changes, Update Accuracy and Start Location Updates
    func startFrequentLocationUpdates(){
        print("Frequent Update Started");
        isMoving = true
        self.locationManager.stopMonitoringSignificantLocationChanges()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.startUpdatingLocation()
    }
    
    // Stop Location Updates, Update Accuracy and Start Significant Changes
    func stopFrequentLocationUpdates(){
        print("Frequent Update Stopped");
        isMoving = false
        self.locationManager.stopUpdatingLocation()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func getHour() -> Int{
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Hour, fromDate:  NSDate())
        return components.hour
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var meters : CLLocationDistance? = 0;
        
        // Check for Time Filter
        if timeFilterEnabled {
            // check whether current time is within the given time limit
            // or ignore the location
            let hour = getHour()
            if hour < timeFilterStart || hour > timeFilterStop {
                print("Hour \(hour) out of range \(timeFilterStart)-\(timeFilterStop)")
                return
            }
        }
        
        // Distance Filter Login Here
        if !isMoving {
            isMoving = true
            self.startFrequentLocationUpdates()
            lastLocation = manager.location!
        }else{
            startStopDetectionTimer()
            
            if let location = manager.location {
                let currentLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                meters = lastLocation!.distanceFromLocation(currentLocation)
            }
            
            if distanceFilterEnabled {
                // Check distance between last location and current location
                // if that is above the distanceFilter
                if meters < distanceFilter{
                    return
                }
            }
        }
        
        print("Distance from last: \(meters!)");
        
        lastLocation = manager.location
        if debug {
            showNotification(manager.location!.coordinate, meters: meters!);
        }
    }
    
    func startStopDetectionTimer(){
        if let t = timer{
            t.invalidate()
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("timerFired"), userInfo: nil, repeats: false)
    }
    
    // Stop Frequent Updates
    func timerFired(){
        self.stopFrequentLocationUpdates()
    }
    
    func showNotification(let coordinate : CLLocationCoordinate2D, let meters: CLLocationDistance){
        print("Location updated: \(coordinate.latitude), \(coordinate.longitude)")
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 1)
        
        notification.alertBody = "Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude), Disnance: \(meters)"
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        lastLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

