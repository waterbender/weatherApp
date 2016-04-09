//
//  ViewController.swift
//  WeatherProject
//
//  Created by  ZHEKA on 15.02.16.
//  Copyright © 2016  ZHEKA. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var backgroundView: UIView?
    @IBOutlet weak var degreePanelView: UIView?
    @IBOutlet weak var bootomPanel: UIView?
    @IBOutlet weak var underBackgroundView: UIView!
    @IBOutlet weak var weatherLabel: UILabel?
    @IBOutlet weak var dayLabel: UILabel?
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var rainLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var placeLabel: UILabel!
    
    var locationManager:CLLocationManager!
    let userAPI = "d69d77ed2b4224a99ddda88600e3bdc7"
    var location: (lat: Double?, lon: Double?)
    var isRefreshing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        //MARK: effects
        if let backView = underBackgroundView {
            addBlurEffect(backView, style: .Dark)
        }
        
        if let botPanel = bootomPanel, let weatLbl = weatherLabel {
            addShadowEffect(botPanel)
            addShadowEffect(weatLbl)
        }
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: ADDING VIEWS AND BAR EFFECTS
    func addBlurEffect(view: UIView, style: UIBlurEffectStyle) {
        
        view.backgroundColor = UIColor.clearColor()
        
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.insertSubview(blurEffectView, atIndex: 0)
        
    }
    
    func addShadowEffect(view: UIView) {
        
        view.layer.shadowColor = UIColor.blackColor().CGColor;
        view.layer.shadowOffset = CGSizeMake(0, 3);
        view.layer.shadowOpacity = 4;
        view.layer.shadowRadius = 5.0;
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    //MARK: location
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        //Do What ever you want with it
    
        if location.lon != nil && location.lat != nil {
            self.location = (lat: lat, lon: long)
        } else {
            self.location = (lat: lat, lon: long)
            refreshWeather({ (compliteed) in
            })
        }
    }
    
    //MARK: refreshWeathere
    
    func refreshWeather(complition: (compliteed: Bool) ->()) {
        
        //MARK: APIServices
        let forecast = ForecastService(api: userAPI)
        
        if let lat = location.lat, let lon = location.lon {
        
        forecast.getWeather(lat, lon: lon) {(let currentWeather) in
            
            if let currentWeather = currentWeather {
                
                dispatch_after(0, dispatch_get_main_queue(), { () -> Void in
                    if let temperature = currentWeather.temperature {
                        let tmp = Int(round((temperature - 32) / 1.8))
                        
                        self.degreeLabel.text = "\(tmp)º"
                    }
                    if let humidity = currentWeather.humidity {
                        self.humidityLabel.text = "\(humidity)"
                    }
                    if let rain = currentWeather.rain {
                        self.rainLabel.text = "\(rain)"
                    }
                    if let day = currentWeather.day {
                        self.dayLabel?.text = "Day: \(day)"
                    }
                    
                    let loc = CLLocation.init(latitude: lat, longitude: lon)
                    
                    CLGeocoder().reverseGeocodeLocation(loc, completionHandler: { (myPlacements, myError) in
                        
                        if let myPlacement = myPlacements?.first, let locality = myPlacement.locality, let country = myPlacement.country {
                            
                            let myAddress = " \(locality), \(country)"
                            
                            self.placeLabel.text = myAddress
                        }
                    })
                    
                    complition(compliteed: true)
                })
            }
        }
       }

    }

    //MARK: swipeRecognizer

    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.Down:
                print("Swiped down")
 
                if isRefreshing {
                    break
                } else {
                    isRefreshing = true
                }
                
                self.activityIndicator.startAnimating()
                UIView.animateWithDuration(1, animations: {
                    
                    if let backViv = self.backgroundView {
                        
                        let centerView: CGPoint = backViv.center
                        backViv.center = CGPointMake(centerView.x, centerView.y+20)
                    }
                    
                    }, completion: { (let valueBool) in
        
                        self.refreshWeather({ (compliteed) in
                                
                                UIView.animateWithDuration(0.5, animations: {
                                if let backViv = self.backgroundView {
                                    
                                    self.activityIndicator.stopAnimating()
                                    let centerView: CGPoint = backViv.center
                                    backViv.center = CGPointMake(centerView.x, centerView.y-20)
                                    self.isRefreshing = false
                                    
                                }
                            })
                        })
                })
                
            default:
                break
            }
        }
    }
}
