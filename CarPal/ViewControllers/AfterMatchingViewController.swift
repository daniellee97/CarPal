//
//  AfterMatchingViewController.swift
//  CarPal
//
//  Created by Daniel Lee on 11/24/19.
//  Copyright © 2019 Daniel Lee. All rights reserved.
//

import UIKit
import MapKit

class AfterMatchingViewController: UIViewController {
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var arrivedButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        transitionToFirstPage()
    }
    
    @IBAction func arrivedButtonTapped(_ sender: Any) {
        createAlert(title: "Thank You", message: "Thank you for riding")
    }
    
    // create popup message
    private func createAlert (title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion:nil)
            self.transitionToHomePage()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // transition to home page
    private func transitionToHomePage(){
        let homeController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.HomeViewController) as? HomeViewController
        view.window?.rootViewController = homeController
        view.window?.makeKeyAndVisible()
    }
    
    // transition to first page
    private func transitionToFirstPage(){
        let firstController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.FirstPageController) as? ViewController
        view.window?.rootViewController = firstController
        view.window?.makeKeyAndVisible()
    }
}

