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
    @IBOutlet weak var enterButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    // location manager constant
    let locationManager = CLLocationManager()
    let regionInMeter: Double = 10000
    var previousLocation: CLLocation?
    var directionsArray = [MKDirections]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check location service
        checkLocationServices()

        // Do any additional setup after loading the view.
        setUpElement()
        signOutButton.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        signOutButton.layer.cornerRadius = 15.0
        signOutButton.tintColor = UIColor.black
    }
    
    @IBAction func enterButtonTapped(_ sender: Any) {
        getAddress()
    }
    
    @IBAction func matchButtonTapped(_ sender: Any) {
        
    }
    
    
    func getAddress() {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(addressTextField.text!) { (placemarks, error) in
            guard let placemakrs = placemarks, let location = placemarks?.first?.location
                else {
                    print("No location found!")
                    return
            }
            self.mapThis(destinationCord: location.coordinate)
        }
    }

    func mapThis(destinationCord: CLLocationCoordinate2D) {
        let sourceCordinate = locationManager.location?.coordinate
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCordinate!)
        let destPlacemark = MKPlacemark(coordinate: destinationCord)
        
        let sourceItem = MKMapItem (placemark: sourcePlacemark)
        let destItem = MKMapItem(placemark: destPlacemark)
        
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.destination = destItem
        destinationRequest.transportType = .automobile
        destinationRequest.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: destinationRequest)
        direction.calculate{ (response, error) in
            guard let response = response else {
                if let error = error {
                    print("Something is wrong!")
                }
                return
            }
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
        resetMapView(withNew: direction)
            
    }
    
    func resetMapView (withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map {$0.cancel()}
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        transitionToFirstPage()
    }
    
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
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled(){
            setUpLocationManager()
            checkLocationAutorization()
        }else {
            // show message that notify the user to turn on the location service
            
        }
    }
    
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
    
    func startTrackingUserLocation(){
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    private func setUpElement(){
        Utilities.styleFilledButton(matchingButton)
        Utilities.styleFilledButton(enterButton)
    }
    
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
