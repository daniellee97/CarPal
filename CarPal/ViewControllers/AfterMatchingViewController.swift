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
    @IBOutlet weak var getDirectionButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        transitionToFirstPage()
    }
    
    private func transitionToFirstPage(){
        let firstController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.FirstPageController) as? ViewController
        view.window?.rootViewController = firstController
        view.window?.makeKeyAndVisible()
    }

    @IBAction func getDirectionButtonTapped(_ sender: Any) {
        
    }
}
