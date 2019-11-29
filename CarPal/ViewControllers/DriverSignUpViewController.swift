//
//  DriverSignUpViewController.swift
//  CarPal
//
//  Created by Daniel Lee on 9/21/19.
//  Copyright © 2019 Daniel Lee. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class DriverSignUpViewController: UIViewController{
    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var SJSUIDTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var zipcodeTextField: UITextField!
    @IBOutlet weak var plateNumberTextField: UITextField!
    @IBOutlet weak var venmoID: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
           super.viewDidLoad()
           
           // Do any additional setup after loading the view.
           setupElements()
       }
    
    // set up elements
    private func setupElements(){
        // hide error label
        errorLabel.alpha = 0
        
        // design textfields
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(SJSUIDTextField)
        Utilities.styleTextField(addressTextField)
        Utilities.styleTextField(cityTextField)
        Utilities.styleTextField(zipcodeTextField)
        Utilities.styleTextField(plateNumberTextField)
        Utilities.styleTextField(venmoID)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signUpButton)
    }
    
    // display error
    private func displayError(_ error: String) {
        errorLabel.text  = error
        errorLabel.alpha = 1
    }
    
    private func validateTextField() -> String? {
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || SJSUIDTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || addressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || cityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || zipcodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || plateNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || venmoID.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please, fill in all fields"
        }
        
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        //Check password is secured
        if !Utilities.isPasswordValid(cleanedPassword) {
            return "Please, make sure your password is at least 8 characters, containing letter, number and special character"
        }
        return nil
    }
    
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        // validate the fields
        let error = validateTextField()
        if error != nil {
            displayError(error!)
        }else {
           
            //create cleaned version of the data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let SJSUID = SJSUIDTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let address = addressTextField.text!
            let city = cityTextField.text!
            let zipcode = zipcodeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let plateNumber = plateNumberTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let venmo = venmoID.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                
                // check for error
                if err != nil {
                    //There was an error
                    self.displayError("Error occurs while creating user")
                } else {
                    //User was created
                    let db = Firestore.firestore()
                    db.collection("drivers").addDocument(data: ["email": email, "password": password, "first_name": firstName, "last_name": lastName, "SJSUID": SJSUID, "address": address, "city": city, "zipcode": zipcode, "vehicle_plate_number": plateNumber, "venmo": venmo, "uid": result!.user.uid]) { (error) in
                        if error != nil {
                            
                            //show error
                            self.displayError("Error happened while saving user data")
                        }
                    }
                }
            }
            // transition to the main screen
            transitionToFisrtPage()
        }
    
    }
    
    private func transitionToFisrtPage() {
        let FirstPageController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.FirstPageController) as? ViewController
        view.window?.rootViewController = FirstPageController
        view.window?.makeKeyAndVisible()
    }

}
