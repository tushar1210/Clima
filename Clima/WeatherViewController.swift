//
//  ViewController.swift
//  WeatherApp
//
//  Created by Tushar Singh on 12/05/18.
//  Copyright © 2018 Tushar Singh. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController,CLLocationManagerDelegate,ChangeCityDelegate{
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "c56c8d224123450ec65213a94a499aa4"
    

    //TODO: Declare instance variables here
   let locationManager=CLLocationManager() 
    let weatherDataModel=WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy=kCLLocationAccuracyHundredMeters            //location within hundered meters
        locationManager.requestWhenInUseAuthorization()           //this is to activate the pop-up for location permission
        locationManager.startUpdatingLocation()             //starts updating location
       
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(parameters:[String:String],url:String){
//        Alamofire.request(url,method: .get, parameters: parameters).responseJSON{
          Alamofire.request(url, method: .get, parameters: parameters).responseJSON{
            response in
            if response.result.isSuccess{
            print("Weather Data Retrieved")
                let json : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: json)
            }
            else{
                print("Error : \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
        
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    func updateWeatherData(json : JSON){
        if let tempResults = json["main"]["temp"].double{
        
        weatherDataModel.temp=Int(tempResults-273.15)
        weatherDataModel.city=json["name"].stringValue
        weatherDataModel.condition=json["weather"][0]["id"].intValue
        weatherDataModel.weathorIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        updateUIWithWeatherData()
        }
        else{
            cityLabel.text="Weather Unavailable"
        }
    
    }
        
    
    //Write the updateWeatherData method here:
    

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    
    
    func updateUIWithWeatherData(){
        cityLabel.text=weatherDataModel.city
        temperatureLabel.text=("\(weatherDataModel.temp)°")
        weatherIcon.image = UIImage(named:weatherDataModel.weathorIconName)
        
    }
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager:CLLocationManager , didUpdateLocations locations: [CLLocation]){
        let location = locations[locations.count-1]
        if location.horizontalAccuracy>0{
           
            print("longitude = ",location.coordinate.longitude,"Latitude = ",location.coordinate.latitude)
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            let longitude = String (location.coordinate.longitude)
            let latitude = String (location.coordinate.latitude)
            let params : [String:String] = ["lat":latitude,"lon":longitude,"appid":APP_ID]
            getWeatherData(parameters:params,url:WEATHER_URL)
            
        }
        
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager:CLLocationManager, didFailWithError error: Error){
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    func userEnteredANewCityName(city: String) {
        print(city)
        let params = ["q": city,"appid":APP_ID]
        getWeatherData(parameters: params, url: WEATHER_URL)
        
    }
    
    //Write the userEnteredANewCityName Delegate method here:
    

    
    //Write the PrepareForSegue Method here
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate=self
        }
    }
    
    
}


