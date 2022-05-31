//
//  MyMapVC.swift
//  SimX
//
//  Created by Hashmi on 29/03/2022.
//  Copyright © 2022 Agilio. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import Toaster

class MyMapVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var doneBtn: UIButton!
    @IBAction func doneBtn(_ sender: Any) {
        
        if lat.isEmpty == true{
            Toast.init(text: "Select Location").start()
        }else{
            callback?(lat, long, addressString)
            dismiss(animated: false, completion: nil)
        }
    }
    
    @IBOutlet weak var pointerBtn: UIButton!
    @IBAction func pointerBtn(_ sender: Any) {
    }
    
   
    @IBOutlet weak var pointerImgView: UIImageView!
    @IBOutlet weak var myMapView: GMSMapView!
    var callback : ((String, String, String) -> Void)?
    var addressString = ""
    var lat = ""
    var long = ""
    var locationManager = CLLocationManager()
    let didFindMyLocation = false
    var location: Bool = false
    var markerPosition : CGPoint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeTheLocationManager()
        self.myMapView.isMyLocationEnabled = true
        myMapView.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
          switch (CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
              print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
              print("Access")
          }
        } else {
          print("Location services are not enabled")
        }
    
        showCurrentLocation()
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(imgTapAction))
        pointerImgView.addGestureRecognizer(imgTap)
        
    }
    
    
    func showCurrentLocation() {
        myMapView.settings.myLocationButton = true
        let locationObj = locationManager.location as! CLLocation
        let coord = locationObj.coordinate
        let lattitude = coord.latitude
        let longitude = coord.longitude

        let center = CLLocationCoordinate2D(latitude: locationObj.coordinate.latitude, longitude: locationObj.coordinate.longitude)
        let marker = GMSMarker()
        marker.position = center
        marker.title = "current location"
        marker.map = myMapView
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 55.943723, longitude: -3.189285, zoom: Float(15.0))
        self.myMapView.animate(to: camera)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        doneBtn.layer.cornerRadius = 15.0
        doneBtn.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
       
       // pointerBtn.isSelected = !pointerBtn.isSelected
        
        //if pointerBtn.isSelected {
            
            pointerBtn.backgroundColor = UIColor.clear
            pointerImgView.backgroundColor = UIColor.clear
            print(coordinate.latitude, coordinate.longitude)
            self.lat = "\(coordinate.latitude)"
            self.long =  "\(coordinate.longitude)"
            getAddressFromGeocodeCoordinate(coordinate: coordinate)
//        }else{
//           print("nothing")
//        }
        
    }
    func getAddressFromGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            
            //Add this line
            if let address = response?.firstResult() {
                let lines = address.lines! as [String]
                let add = lines.joined(separator: " ")
                self.addressString = add
                Toast.init(text: add).show()
            }
        }
    }
    
    func initializeTheLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                // Handle location update
            }
        locationManager.stopUpdatingHeading()
    }
    func cameraMoveToLocation(toLocation: CLLocationCoordinate2D?) {
           if toLocation != nil {
               myMapView.camera = GMSCameraPosition.camera(withTarget: toLocation!, zoom: 15)
           }
       }
    
//    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
//            if marker == mapMarker{
//
//                self.markerPosition = self.mapView.projection.point(for: CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude))
//
//                print("End Dragging")
//            }
//        }
    
    
    @objc func imgTapAction(){
        print("not")
        self.location = true
    }

}
