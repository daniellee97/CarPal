//
//  SignUpViewController.swift
//  CarPal
//
//  Created by Daniel Lee on 9/16/19.
//  Copyright © 2019 Daniel Lee. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class NonDriverSignUpViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var SJSUIDTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupElements()
    }
    func setupElements() {
        // hide error lable
        errorLabel.alpha = 0
        
        //style the elements
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(SJSUIDTextField)
        Utilities.styleTextField(addressTextField)
        Utilities.styleTextField(cityTextField)
        Utilities.styleTextField(zipCodeTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signUpButton)
        
    }
    
    /* checks the fields and validate that the data is correct.
    If everything is correct, then it will return nil. Otherwise, it returns the error messages*/
    func validateField() -> String?{
        //check that all fields are filled in
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            SJSUIDTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            addressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            cityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            zipCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please, fill in all fields"
        }
        
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        //Check password is secured
        if !Utilities.isPasswordValid(cleanedPassword) {
            return "Please, make sure your password is at least 8 characters, containing letter, number and special character"
        }
        
        return nil
    }
    
    @IBAction func signUp(_ sender: Any) {
        // validate the fields
        let error = validateField()
        if error != nil {
            displayError(error!)
        }else {
           
            //create cleaned version of the data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let SJSUID = SJSUIDTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let address = addressTextField.text!
            let city = cityTextField.text!
            let zipcode = zipCodeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
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
                    db.collection("riders").addDocument(data: ["email": email, "password":password, "first_name": firstName, "last_name": lastName, "SJSUID": SJSUID, "address": address, "city": city, "zipcode": zipcode, "uid": result!.user.uid]) { (error) in
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
    
    private func displayError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    private func transitionToFisrtPage() {
        let firstPageController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.FirstPageController) as? ViewController
        view.window?.rootViewController = firstPageController
        view.window?.makeKeyAndVisible()
    }

}
