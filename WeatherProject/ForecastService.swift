//
//  ForecastService.swift
//  WeatherProject
//
//  Created by  ZHEKA on 15.02.16.
//  Copyright © 2016  ZHEKA. All rights reserved.
//

import Foundation

struct ForecastService {
    
    let userAPI: String
    let forecastBaseUrlLink: NSURL?
    typealias WeatherResult = (compplitionWeather: CurrentWeather) -> ()
    
    init(api: String) {
        
        self.userAPI = api
        self.forecastBaseUrlLink =  NSURL(string: "https://api.forecast.io/forecast/\(self.userAPI)/")
    }
    
    func getWeather(lat: Double, lon: Double, complition: (CurrentWeather? -> ())) {
        
        if let forecastURL = NSURL(string: "\(lat),\(lon)", relativeToURL: self.forecastBaseUrlLink) {
            
            let networkOperation = NetworkOperation(downloadURL: forecastURL)
            
            networkOperation.downloadJsonFromURL({ (let dictResult) -> () in
                
                let weather = self.weatherFromDictionary(dictResult)
                complition(weather)
            })

        }
    }
    
    func weatherFromDictionary(jsonDict: [String: AnyObject]?) -> CurrentWeather? {
        
        if let currentWeatherDict = jsonDict?["currently"] as? [String: AnyObject]{
            return CurrentWeather(weatherDict: currentWeatherDict)
        } else {
            print("JSON dictionary returned nil for currently key")
            return nil
        }
    }
}