//
//  CurrentWeather.swift
//  WeatherProject
//
//  Created by  ZHEKA on 15.02.16.
//  Copyright © 2016  ZHEKA. All rights reserved.
//

import Foundation

struct CurrentWeather {
 
    var temperature: Double?
    var humidity: Int?
    var rain: Int?
    var summary: String?
    var day: String?
    let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    
    init(weatherDict: [String: AnyObject]) {
        
        temperature = weatherDict["temperature"] as? Double
        
        if let humidity = weatherDict["humidity"] as? Double {
            self.humidity = Int(humidity*100)
        } else {
            self.humidity = nil
        }
        
        if let rain = weatherDict["precipProbability"] as? Double {
            self.rain = Int(rain*100)
        } else {
            self.rain = nil
        }

        self.summary = weatherDict["summary"] as? String
        
        self.day = getCurrentDay()
        
    }
    
    func getCurrentDay() -> String {
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let day = calendar.component(.Weekday, fromDate: date)
        
        return ("\(daysOfWeek[day-1])")
    }
    
}