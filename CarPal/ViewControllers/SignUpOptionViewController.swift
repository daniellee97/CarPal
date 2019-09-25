//
//  SignUpOptionViewController.swift
//  CarPal
//
//  Created by Daniel Lee on 9/23/19.
//  Copyright © 2019 Daniel Lee. All rights reserved.
//

import UIKit

class SignUpOptionViewController: UIViewController {

    
    @IBOutlet weak var driverSignUpButton: UIButton!
    @IBOutlet weak var nonDriverSignUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        Utilities.styleFilledButton(driverSignUpButton)
        Utilities.styleFilledButton(nonDriverSignUpButton)
        
    }

}
