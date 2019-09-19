//
//  SignInViewController.swift
//  CarPal
//
//  Created by Daniel Lee on 9/16/19.
//  Copyright © 2019 Daniel Lee. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func signInTapped(_ sender: Any) {
        
        //validate text field
        let error = validateField()
        if error != nil {
            displayError(error!)
        }else {
            
        }
        
        //create cleaned version of the text fields
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //signing in user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil{
                // fail signing in
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.alpha = 1
            } else {
                self.transitionToMainPage()
            }
        }
        
    }
    
    // Transition to main page
    private func transitionToMainPage(){
        let homeViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.HomeViewController) as? HomeViewController
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    /* checks the fields and validate that the data is correct.
     If everything is correct, then it will return nil. Otherwise, it returns the error messages*/
    private func validateField() -> String?{
        //check that all fields are filled in
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please, fill in all fields"
        }
        
        return nil
    }
    
    //Display error message
    private func displayError(_ message: String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    
    private func setUpElements() {
        
        // hide error label
        errorLabel.alpha = 0
        
        // set up elements
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signInButton)
    }

}
