//
//  HomeViewController.swift
//  CarPal
//
//  Created by Daniel Lee on 9/16/19.
//  Copyright © 2019 Daniel Lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class HomeViewController: UIViewController{

    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var matchingButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var arrivedButton: UIButton!
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    // location manager constant
    let locationManager = CLLocationManager()
    let regionInMeter: Double = 10000
    var previousLocation: CLLocation?
    var directionsArray = [MKDirections]()
    
    var currentUserAddress = String()
    var currentUserName = String()
    var driver = Driver(first_name: "", last_name: "",plate_number: "", uid: "", venmo_ID: "")
    
    
    
    let db = Firestore.firestore()
    let currentUid = Auth.auth().currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check location service
        checkLocationServices()
        
        // Do any additional setup after loading the view.
        setUpElement()
        mapView.showsTraffic = true
        arrivedButton.isEnabled = false
        arrivedButton.isHidden = true
        signOutButton.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        signOutButton.layer.cornerRadius = 15.0
        signOutButton.tintColor = UIColor.black
    }
    
    @IBAction func arrivedButtonTapped(_ sender: Any) {
        mapThis(destinationCord: locationManager.location!.coordinate)
        enableMatchingButton()
        createAlert(title: "Thank You", message: "Thank you for using our app!")
    }
    
    // action when match button tapped
    @IBAction func matchButtonTapped(_ sender: Any) {
        getAddress(address: addressTextField.text!)
        setHomeAddressOfCurrentUser()
        setClosestDriver()
        
        addressTextField.text = ""
    }
    
    // show matching button and enable it, then remove arrived button
    private func enableMatchingButton(){
        arrivedButton.isEnabled = false
        arrivedButton.isHidden = true
        matchingButton.isEnabled = true
        matchingButton.isHidden = false
    }
    
    //show arrived button and enable it, then remove matching button
    private func enableArrivedButton() {
        arrivedButton.isEnabled = true
        arrivedButton.isHidden = false
        matchingButton.isEnabled = false
        matchingButton.isHidden = true
    }
    
    private func setHomeAddressOfCurrentUser(){
        self.currentUserAddress = addressTextField.text!
    }
    
    // find the closest rider
    private func setClosestRider(){
        
    }
    
    // find the closest driver
    private func setClosestDriver () {
        let limitETA:Double = 5
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(currentUserAddress) { (placemarks, error) in
            guard let placemakrs = placemarks, let location = placemarks?.first?.location
                else {
                    print("No location found!")
                    return
            }
            let riderCoordinate = location.coordinate
            self.db.collection("drivers").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting Document")
                } else {
                    let documents = querySnapshot!.documents
                    for document in documents {
                        // get address
                        let address = document.get("address") as! String
                        
                        //get coordinate of driver's home location
                        let geoCoder = CLGeocoder()
                        geoCoder.geocodeAddressString(address) { (placemarks, error) in
                            guard let placemakrs = placemarks, let location = placemarks?.first?.location
                                else {
                                    print("No location found!")
                                    return
                            }
                            let driverCoordinate = location.coordinate
                            let first_name = document.get("first_name") as! String
                            let last_name = document.get("last_name") as! String
                            let uid = document.get("uid") as! String
                            let plate_number = document.get("vehicle_plate_number") as! String
                            let venmoID = document.get("venmo") as! String
                            self.getETA(startingCord: driverCoordinate, destinationCord: riderCoordinate, firstName: first_name, lastName: last_name, plateNumber: plate_number, uid: uid, venmoID: venmoID)
                        }
                    }
                }
            }
        }
    }
    
    private func setDriverInfo(first_name:String, last_name:String, uid:String, plate_number:String, venmoID:String) {
        self.driver.first_name = first_name
        self.driver.last_name = last_name
        self.driver.uid = uid
        self.driver.plate_number = plate_number
        self.driver.venmo_ID = venmoID
    }
    
    // create popup message
    private func createAlert (title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion:nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // get the address from the address text field
    private func getAddress(address: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard let placemakrs = placemarks, let location = placemarks?.first?.location
                else {
                    print("No location found!")
                    return
            }
            self.mapThis(destinationCord: location.coordinate)
        }
    }
    
    // get MKDirections.request()
    private func getRequest(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> MKDirections.Request{
        let sourcePlacemark = MKPlacemark(coordinate: from)
        let destPlacemark = MKPlacemark(coordinate: to)
        
        let sourceItem = MKMapItem (placemark: sourcePlacemark)
        let destItem = MKMapItem(placemark: destPlacemark)
        
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.destination = destItem
        destinationRequest.transportType = .automobile
        destinationRequest.requestsAlternateRoutes = true
        
        return destinationRequest
    }

    // calculate the route and display on the map view
    private func mapThis(destinationCord: CLLocationCoordinate2D){
        let destinationRequest = getRequest(from: locationManager.location!.coordinate, to: destinationCord)
        
        let direction = MKDirections(request: destinationRequest)
        resetMapView(withNew: direction)
        direction.calculate{ (response, error) in
            guard let response = response else {
                if let error = error {
                    print("Something is wrong! \(error)")
                }
                return
            }
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
        
    }
    
    
    // calculate and return the eta of the route
    func getETA (startingCord: CLLocationCoordinate2D, destinationCord: CLLocationCoordinate2D, firstName:String, lastName:String, plateNumber:String, uid:String, venmoID:String){
        var ETAInMin:Double = 0
        let destinationRequest = getRequest(from: startingCord, to: destinationCord)
        
        let direction = MKDirections(request: destinationRequest)
        direction.calculate { response, error in
            guard error == nil, let response = response else {return}
            let route = response.routes[0]
            ETAInMin = route.expectedTravelTime/60
            if ETAInMin < 10 {
                print("it will take \(ETAInMin)")
                self.setDriverInfo(first_name: firstName, last_name: lastName, uid: uid, plate_number: plateNumber, venmoID: venmoID)
                self.createAlert(title: "MATCHED!", message: "Driver is: \(self.driver.first_name) \(self.driver.last_name)\n Plate number is: \(self.driver.plate_number)\n Meeting point: In front of the Student Union \n Venmo ID: \(self.driver.venmo_ID)")
                
                // enable arrived button
                self.enableArrivedButton()
            } else {
                // create pop up menu with match failed message
                self.createAlert(title: "MATCH FAILED!", message: "No available Drivers")
                
            }
        }

    }
    
    //reset mapview every time when user types different address
    func resetMapView (withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map {$0.cancel()}
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        transitionToFirstPage()
    }
    
    // transition to first screen
    private func transitionToFirstPage(){
        let firstController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.FirstPageController) as? ViewController
        view.window?.rootViewController = firstController
        view.window?.makeKeyAndVisible()
    }
    
    // setting up location manager
    private func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // check the location service
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled(){
            setUpLocationManager()
            checkLocationAutorization()
        }else {
            // show message that notify the user to turn on the location service
            
        }
    }
    
    // make the map view always center to the user's location
    func centerViewOnUserLocation () {
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeter, longitudinalMeters: regionInMeter)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // check location authorization
    private func checkLocationAutorization() {
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            startTrackingUserLocation()
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        }
    }
    
    // track the user's location
    func startTrackingUserLocation(){
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    private func setUpElement(){
        Utilities.styleFilledButton(matchingButton)
        Utilities.styleFilledButton(arrivedButton)
    }
    
    // get the location of the center of the screen
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }

}

extension HomeViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{ return }
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeter, longitudinalMeters: regionInMeter)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAutorization()
    }
    
    

    func mapView (_ mapview: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .blue
        return render
    }
    
}


extension HomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else { return }
        
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in guard let self = self else { return }
            
            if let _ = error {
                return
            }
            
            guard let placemark = placemarks?.first else {
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, renderFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        
        renderer.strokeColor = .blue
        
        return renderer
    }
}
