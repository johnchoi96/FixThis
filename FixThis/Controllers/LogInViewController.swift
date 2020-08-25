//
//  LogInViewController.swift
//  FixThis
//
//  Created by John Choi on 8/24/20.
//  Copyright © 2020 John Choi. All rights reserved.
//

import UIKit
import Firebase
import LocalAuthentication
import KeychainSwift

class LogInViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var spinnerView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var logInButton: UIButton!
    
    @IBOutlet weak var loginView: UIButton!
    @IBOutlet weak var useBiometricButton: UIButton!
    
    let defaults = UserDefaults.standard
    let keychain = KeychainSwift()
    let localAuthenticationContext = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // delegate setup
        emailField.delegate = self
        passwordField.delegate = self
//        self.navigationItem.largeTitleDisplayMode = .never
        
        spinnerView.isHidden = true
        spinnerView.layer.cornerRadius = 10
        spinnerView.alpha = 0.7
        if let email = defaults.string(forKey: "email") {
            emailField.text = email
        }
        logInButton.isEnabled = true
        
        loginView.layer.cornerRadius = 25

        // try to log in with biometric method
        // grab email and password from keychain
        // check if credentials exist in keychain
        if let userEmail = keychain.get("userEmail"), let userPassword = keychain.get("userPassword") {
            logInWithBiometrics(email: userEmail, password: userPassword)
        } else {
            useBiometricButton.isEnabled = false
            emailField.becomeFirstResponder()
        }
    }
    
    @IBAction func logInPressed(_ sender: UIButton) {
        logIn()
    }
    
    /**
     Tries to log in the user with email and password provided.
     Performs integrity check on email and password to see if they fulfill the requirement and attempts log in.
     If log in is successful, asks the user if they want to opt in for a biometric authentication using UIAlertController and UIAlertAction.
     */
    private func logIn() {
        spinnerView.isHidden = false
        spinner.startAnimating()
        
        if checkEmail() && checkPassword() {
            // try logging in
            // if successful, call performSegue()
            Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                // issue signing in the user
                if error != nil {
                    strongSelf.spinner.stopAnimating()
                    strongSelf.spinnerView.isHidden = true
                    strongSelf.logInButton.isEnabled = true
                    let alert = UIAlertController(title: "Sign in failed!", message: "There was a problem signing in", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    strongSelf.present(alert, animated: true, completion: {
                        return
                    })
                }
                strongSelf.spinner.stopAnimating()
                strongSelf.spinnerView.isHidden = true
                
                // login should be successful so save the email to UserDefaults
                strongSelf.defaults.set(strongSelf.emailField.text!, forKey: "email")
                
                // authentication method
                let authenticationMethod = K.BIOMETRIC_METHOD
                // ask the user if user wants to use biometric authentication in the future
                let alert = UIAlertController(title: String(format: "Would you like to use %@ to authenticate?", authenticationMethod), message: "", preferredStyle: .alert)
                let action = UIAlertAction(title: "Yes", style: .default) { (action) in
                    strongSelf.keychain.set(strongSelf.emailField.text!, forKey: "userEmail")
                    strongSelf.keychain.set(strongSelf.passwordField.text!, forKey: "userPassword")

                    strongSelf.performSegue(withIdentifier: K.Segues.loginToMain, sender: self)
                }
                let noAction = UIAlertAction(title: "No", style: .cancel) { (action) in
                    strongSelf.keychain.delete("userEmail")
                    strongSelf.keychain.delete("userPassword")
                    strongSelf.performSegue(withIdentifier: K.Segues.loginToMain, sender: self)
                }
                alert.addAction(action)
                alert.addAction(noAction)
                strongSelf.present(alert, animated: true, completion: nil)
            }
            
        } else {
            spinner.stopAnimating()
            spinnerView.isHidden = true
        }
    }
    
    @IBAction func useBiometricPressed(_ sender: UIButton) {
        logInWithBiometrics(email: keychain.get("userEmail")!, password: keychain.get("userPassword")!)
    }
    
    /**
     Attempts log in using the biometric authentication method.
     This is called immediately after the view is loaded if the email and password exist in the Apple Keychain.
     - Parameter email: user email extracted from Apple Keychain
     - Parameter password: user password extracted from Apple Keychain
     */
    private func logInWithBiometrics(email: String, password: String) {
        localAuthenticationContext.localizedFallbackTitle = "Enter Email/Password"
        
        // check if biometric is available
        var authorizationError: NSError?
        if localAuthenticationContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &authorizationError) {
            print("Biometrics is supported")
            switch localAuthenticationContext.biometryType {
            case .faceID:
                fallthrough
            case .touchID:
                localAuthenticationContext.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: "Log In") { (success, error) in
                    if success {
                        print("Success")
                        
                        // try logging in
                        // if successful, call performSegue()
                        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                            guard let strongSelf = self else { return }
                            // issue signing in the user
                            if error != nil {
                                strongSelf.spinner.stopAnimating()
                                strongSelf.spinnerView.isHidden = true
                                strongSelf.logInButton.isEnabled = true
                                let alert = UIAlertController(title: "Sign in failed!", message: "There was a problem signing in", preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(action)
                                strongSelf.present(alert, animated: true, completion: {
                                    return
                                })
                            }
                            strongSelf.spinner.stopAnimating()
                            strongSelf.spinnerView.isHidden = true
                            // login should be successful so save the email to UserDefaults
                            strongSelf.defaults.set(strongSelf.emailField.text!, forKey: "email")
                            strongSelf.performSegue(withIdentifier: K.Segues.loginToMain, sender: self)
                        }
                    } else {
                        print("Error \(String(describing: error))")
                    }
                }
            default:
                print("Biometric not available")
            }
            
        }
    }
    
    /**
     Returns true if the email in the email text field is a valid email.
     - Returns: true if the email entry is a valid email
     */
    private func checkEmail() -> Bool {
        if let email = emailField.text {
            if !email.isValidEmail() {
                let alert = UIAlertController(title: "Invalid email!", message: "Please enter a valid email", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    /**
     Returns true if the password in the password text field is not empty.
     - Returns: true if the password text field is not empty
     */
    private func checkPassword() -> Bool {
        if let password = passwordField.text {
            if password.count == 0 {
                let alert = UIAlertController(title: "Please enter password", message: "", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
}

// MARK: - UITextField delegate section
extension LogInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            if !checkEmail() {
                return false
            }
            passwordField.becomeFirstResponder()
        } else {
            if !checkPassword() {
                return false
            }
            logInButton.isEnabled = false
            textField.resignFirstResponder()
            logIn()
        }
        return true
    }
}
