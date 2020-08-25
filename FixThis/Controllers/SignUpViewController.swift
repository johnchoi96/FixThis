//
//  SignUpViewController.swift
//  FixThis
//
//  Created by John Choi on 8/24/20.
//  Copyright © 2020 John Choi. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var spinnerView: UIView!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var signupView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        emailField.becomeFirstResponder()
        spinnerView.layer.cornerRadius = 10
        spinnerView.alpha = 0.7
        spinnerView.isHidden = true
        
        signupView.layer.cornerRadius = 25
    }
    
    /**
     Checks if the user input a valid email and password before performing the segue to the main screen.
     - Parameter sender: button that was pressed
     */
    @IBAction func signupPressed(_ sender: UIButton) {
        signUp()
    }
    
    /**
     Signs up the user using the email and password in the respective text fields.
     If sign up was successful, asks the user if they want to opt in for the biometric authentication.
     */
    private func signUp() {
        guard let email = emailField.text, email.count > 0 else {
            displayAlert(title: "Please enter email!", message: "Email must be provided")
            signUpButton.isEnabled = true
            emailField.becomeFirstResponder()
            return
        }
        // if email is invalid, do not let the user finish sign up
        if !email.isValidEmail() {
            displayAlert(title: "Invalid email!", message: "Please enter a valid email!")
            signUpButton.isEnabled = true
            emailField.becomeFirstResponder()
            return
        }
        if !isValidPassword() || !passwordsMatch() {
            signUpButton.isEnabled = true
            passwordField.becomeFirstResponder()
            return
        }
        spinnerView.isHidden = false
        spinner.startAnimating()
        // Firebase Auth create user
        Auth.auth().createUser(withEmail: email, password: passwordField.text!) { authResult, error in
            if error != nil {
                var alertTitle = "There was a issue signing up the user"
                var alertMessage = "Please try again later"
                if error!.localizedDescription == "The email address is already in use by another account." {
                    alertTitle = "The email address is already in use by another account"
                    alertMessage = "Please choose another email."
                }
                self.displayAlert(title: alertTitle, message: alertMessage)
                self.spinner.stopAnimating()
                self.spinnerView.isHidden = true
                return
            }

            // save email to UserDefaults
            UserDefaults.standard.set(email, forKey: "email")
            // available authentication method
            let authenticationMethod = K.BIOMETRIC_METHOD
            // ask the user if they want biometric authentication
            let alert = UIAlertController(title: String(format: "Would you like to use %@ to authenticate?", authenticationMethod), message: "", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                // save credentials to keychain
                let keychain = KeychainSwift()
                keychain.set(email, forKey: "userEmail")
                keychain.set(self.passwordField.text!, forKey: "userPassword")
                self.performSegue(withIdentifier: K.Segues.signupToMain, sender: self)
            }
            let noAction = UIAlertAction(title: "No", style: .cancel) { (action) in
                self.performSegue(withIdentifier: K.Segues.signupToMain, sender: self)
            }
            alert.addAction(yesAction)
            alert.addAction(noAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /**
     Checks if the provided password satisfies the security requirement.
     Shows the UIAlert if the check fails and returns false.
     - Returns: true if the password in the password field is valid
     */
    private func isValidPassword() -> Bool {
        if let password = passwordField.text {
            if password.count >= 6 {
                return true
            } else {
                displayAlert(title: "Invalid password!", message: "Passwords must match")
                return false
            }
        } else {
            displayAlert(title: "Invalid password!", message: "Please enter password")
            return false
        }
    }
    
    /**
     Checks if the two entered passwords match.
     If the two passwords do not match, alert is shown.
     - Returns: returns true if the passwords in the two password textfields match.
     */
    private func passwordsMatch() -> Bool {
        if let pw = passwordField.text, let pwConfirm = confirmPasswordField.text {
            if pw == pwConfirm {
                return true
            } else {
                displayAlert(title: "Password mismatch!", message: "Passwords must match")
                return false
            }
        } else {
            displayAlert(title: "Please enter password", message: "")
            return false
        }
    }

    /**
     Displays alert with the provided title and message on current view.
     - Parameter title: title of the alert
     - Parameter message: message of the alert
     */
    private func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate section
extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // user returned from email text field
        if textField.tag == 0 {
            if let email = textField.text {
                if !email.isValidEmail() {
                    displayAlert(title: "Invalid email!", message: "Please enter a valid email!")
                    return false
                }
                passwordField.becomeFirstResponder()
            }
        } else if textField.tag == 1 {
            if isValidPassword() {
                confirmPasswordField.becomeFirstResponder()
                return true
            }
        } else {
            signUpButton.isEnabled = false
            signUp()
            textField.resignFirstResponder()
        }
        return true
    }
    
    /**
     Workaround to avoid the annoying auto-fill for the passwords.
     New password textfield is assigned a tag of 1 and confirm password textifeld is assigned a tag of 2.
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 || textField.tag == 2 {
            textField.isSecureTextEntry = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}

// MARK: - Email validation function for String
extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
