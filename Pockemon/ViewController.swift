//
//  ViewController.swift
//  Pockemon
//
//  Created by tolga iskender on 14.08.2018.
//  Copyright © 2018 tolga iskender. All rights reserved.
//

import UIKit
import GoogleMaps
class ViewController: UIViewController,GMSMapViewDelegate{
    
    let locationManager:CLLocationManager = CLLocationManager()
    var mapView:GMSMapView!
    var myLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var listPockemon = [Pockemons]()
    var playerPower: Double = 0.0
    var index = 0
    let myMarker = GMSMarker()
    var markerCount:Int = 0
    var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        location()
     
       
        }

        
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let newMarioLat = marker.position.latitude
        let newMarioLong = marker.position.longitude
        if marker.icon != UIImage(named: "mario") {
        marker.map = nil
        
        myMarker.position = CLLocationCoordinate2D(latitude: newMarioLat, longitude: newMarioLong)
        
        if markerCount != 1 {
            alertDialog(pockemonPower: Double(marker.snippet!)!)
            markerCount = markerCount - 1
         
        }
        
        else {
            
            let alert = UIAlertController(title: "Game Over", message: "You Catched All Pocketmons", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                
                self.replay()
             
            }))
            self.present(alert, animated: true, completion: nil)
        }
        }
       
        return true
    }
    
    func replay(){
        
        self.myMarker.map = nil
        self.markerCount = 2
        self.playerPower = 0
         self.mapView.clear()
        DispatchQueue.main.async {
          
            self.addMario()
            self.addPockemon()
         
            
        }
        
       
    }
    
    func loadPockemon(lat:Double, log:Double) {
        self.listPockemon.append(Pockemons(latitude:  lat + 0.005 , longitude: log + 0.005, image: "charmander", name: "Charmander", des: "Charmander live in Law", power: Double(arc4random_uniform(100))))
        self.listPockemon.append(Pockemons(latitude: lat - 0.003, longitude: log + 0.006, image: "bulbasaur", name: "Bulbasaur", des: "Bulbasaur live in Jungle", power: Double(arc4random_uniform(100))))
        self.listPockemon.append(Pockemons(latitude: lat - 0.004, longitude: log-0.006, image: "squirtle", name: "Squirtle", des: "Squirtle live in Sea", power: Double(arc4random_uniform(100))))
    }
    
    
    func alertDialog(pockemonPower: Double) {
        playerPower = playerPower + pockemonPower
        
        let alert = UIAlertController(title: "Catch new pockemon", message: "your new power is \(playerPower)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            print("+ one \(self.markerCount)")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
  
    func location() {
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            currentLocation = locationManager.location
            myLocation = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        }
        
        loadPockemon(lat: currentLocation.coordinate.latitude, log: currentLocation.coordinate.longitude)
        
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, zoom: 10)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.view = mapView
        self.mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
  
}
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myLocation = manager.location!.coordinate
        self.mapView.clear()
        
        addMario()
        addPockemon()
        
        
        
        let camera = GMSCameraPosition.camera(withLatitude: myLocation.latitude, longitude: myLocation.longitude, zoom: 15)
        self.mapView.camera = camera
    }
    
    
    func addMario(){
        myMarker.position = CLLocationCoordinate2D(latitude: myLocation.latitude, longitude: myLocation.longitude)
        
        myMarker.title = "Me"
        myMarker.snippet = "Here is my location"
        myMarker.icon = UIImage(named: "mario")
        myMarker.map = self.mapView
        markerCount = markerCount + 1
    }
    
    
    func addPockemon(){
        
        for pockemon in listPockemon {
            
            if pockemon.isCatch == false {
                let markerPockemon = GMSMarker()
                markerPockemon.position = CLLocationCoordinate2D(latitude: pockemon.latitude!, longitude: pockemon.longitude!)
                markerPockemon.title = pockemon.name!
                markerPockemon.snippet = "\(pockemon.power)"
                markerPockemon.icon = UIImage(named: pockemon.image!)
                markerPockemon.map = self.mapView
                
                
                if(Double(myLocation.latitude).rounTo(places: 4) == Double(pockemon.latitude!).rounTo(places: 4)
                    && Double(myLocation.longitude).rounTo(places: 4) == Double(pockemon.longitude!).rounTo(places: 4))
                {
                    listPockemon[index].isCatch = true
                    alertDialog(pockemonPower: pockemon.power)
                }
            }
            index = index+1
        }
        

    }
}
extension Double {
    func rounTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
