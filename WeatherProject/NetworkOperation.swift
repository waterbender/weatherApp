//
//  NetworkOperation.swift
//  WeatherProject
//
//  Created by  ZHEKA on 15.02.16.
//  Copyright © 2016  ZHEKA. All rights reserved.
//

import Foundation

class NetworkOperation {
    

    
    lazy var urlConfig: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    lazy var session: NSURLSession = NSURLSession(configuration: self.urlConfig)
    let queryURL: NSURL
    
    init(downloadURL: NSURL) {
        self.queryURL = downloadURL
    }
    
    typealias ResultClousure = (dictResult: [String: AnyObject]?) -> ()
    
    func downloadJsonFromURL(complition: ResultClousure) {
        let request = NSURLRequest(URL: queryURL)
        
        let dataTask = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            if let httpResponse = response as? NSHTTPURLResponse {
                
                switch httpResponse.statusCode {
                    
                case 200: // 2. Create JSON object with data
                    let jsonObject = (try? NSJSONSerialization.JSONObjectWithData(data!, options: [])) as? [String: AnyObject]
                    
                    complition(dictResult: jsonObject)
                    
                default:
                    print("GET request not successful. HTTP status code: \(httpResponse.statusCode)")
                }

                
            } else {
                
                print("Error: The HTTPResponse is failed")
            }
        }
    
        dataTask.resume()
        
    }
    
}