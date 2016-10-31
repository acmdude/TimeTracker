//
//  InterfaceController.swift
//  Time Tracker WatchKit Extension
//
//  Created by Angelo Micheletti on 10/12/16.
//  Copyright © 2016 Angelo Micheletti. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var button: WKInterfaceButton!
    @IBOutlet var middleLabel: WKInterfaceLabel!
    @IBOutlet var topLabel: WKInterfaceLabel!
    
    var clockedIn = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        updateUI(clockedIn: clockedIn)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateUI(clockedIn: Bool){
        if clockedIn {
            //Set the UI for being Clocked-In
            topLabel.setHidden(false)
            middleLabel.setText("5m 22s")
            button.setTitle("Clocked-Out")
            button.setBackgroundColor(UIColor.red)
        }else {
            //Set the UI for being Clocked-Out
            topLabel.setHidden(true)
            middleLabel.setText("Today\n 3h 44m")
            button.setTitle("Clocked-In")
            button.setBackgroundColor(UIColor.green)
        }
    }
    
    
    @IBAction func clockInOutTapped() {
        if clockedIn == true {
            clockOut()
        }else {
            clockIn()
        }
        
        updateUI(clockedIn: clockedIn)
        
    }
    
    func clockIn(){
        clockedIn = true
        UserDefaults.standard.set(Date(), forKey: "clockedIn")
        UserDefaults.standard.synchronize()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            if let clockedInDate = UserDefaults.standard.value(forKey: "clockedIn") as? Date{
                let timeInterval = Int(Date().timeIntervalSince(clockedInDate))
                
                let hours = timeInterval / 3600
                let minutes = (timeInterval % 3600) / 60
                let seconds = timeInterval % 60
                
                self.middleLabel.setText("\(hours)h \(minutes)m \(seconds)s")
                let totalTimeInterval = timeInterval + self.totalClockedTime()
                let totalHours = totalTimeInterval / 3600
                let totalMinutes = (totalTimeInterval % 3600) / 60
                let totalSeconds = totalTimeInterval % 60
                
                self.topLabel.setText("Today: \(totalHours)h \(totalMinutes)m \(totalSeconds)s")
            }
        }
        
    }
    func clockOut()
    {
        clockedIn = false
        if let clockedInDate = UserDefaults.standard.value(forKey: "clockedIn") as? Date
        {
            //Adding the clockin time to the clockins array
            if var clockIns = UserDefaults.standard.array(forKey: "clockIns") as? [Date]
            {
                clockIns.insert(clockedInDate, at: 0)
                UserDefaults.standard.set(clockIns, forKey: "clockIns")
                print(clockIns)
            } else
            {
                UserDefaults.standard.set([clockedInDate], forKey: "clockIns")
            }
            //Adding the clockouts time to the clockouts array
            if var clockOuts = UserDefaults.standard.array(forKey: "clockOuts") as? [Date]
            {
                clockOuts.insert(Date(), at: 0)
                UserDefaults.standard.set(clockOuts, forKey: "clockOuts")
                print(clockOuts)
            } else
            {
                UserDefaults.standard.set([Date()], forKey: "clockOuts")
            }
            UserDefaults.standard.set(nil, forKey: "clockedIn")
        }
        UserDefaults.standard.synchronize()
        
    } //End of clockOut
    
    func totalClockedTime() -> Int
    {
        if var clockIns = UserDefaults.standard.array(forKey: "clockIns") as? [Date]
        {
            if var clockOuts = UserDefaults.standard.array(forKey: "clockOuts") as? [Date]
            {
                var seconds = 0
                for index in 0..<clockIns.count
                {
                    //Find the difference between clockIn and Out
                    let currentSeconds = Int(clockOuts[index].timeIntervalSince(clockIns[index]))
                    
                   
                    //Add time to seconds
                    seconds += currentSeconds
                   
                }
                //print("Total Seconds: \(seconds)")
                    return seconds
            }
            
        }
        return 0
    }
}
