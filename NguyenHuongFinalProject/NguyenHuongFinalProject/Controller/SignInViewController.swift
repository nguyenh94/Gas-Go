//
//  SignInViewController.swift
//  NguyenHuongFinalProject
//
//  Created by Huong Nguyen on 4/27/22.
//  huongbng@usc.edu
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    private var dataSource = ReceiptModel.sharedInstance
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeLabel.text = String(format: NSLocalizedString("Welcome to Gas$Go!", comment: ""))
        loginButton.setTitle(NSLocalizedString("Login", comment: ""), for: .normal)
        signUpButton.setTitle(NSLocalizedString("Sign Up", comment: ""), for: .normal)
        emailTextField.tag = 0
        emailTextField.delegate = self
        passwordTextField.tag = 1
        passwordTextField.delegate = self
    }
    
    // check for valid email/password and log user in when they click log in button
    @IBAction func loginDidTapped(_ sender: UIButton) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        // return if either text field is empty
        if email.isEmpty || password.isEmpty {
            return
        }
        
        // authorize with firebase auth
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error{ // if there is an error, just print the error and don't do anything else
                print(error)
                return
            }
            
            // user sucessfully signed in
            if let userId = authResult?.user.uid {
                print("User has successfully signed in \(userId)")
                self?.dataSource.reinitializeModel()
            }
            // If successful, show the Welcome Screen
            // have to use self keyword when executing a method inside a closure
            DispatchQueue.main.async {
                self?.emailTextField.text = ""
                self?.passwordTextField.text = ""
                self?.performSegue(withIdentifier: "tabBarSegue", sender: nil) // show the home screen
            }
        }
    }
    
    // go back to sign up screen when user click sign up
    @IBAction func signUpDidTapped(_ sender: UIButton) {
        emailTextField.text = ""
        passwordTextField.text = ""
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // make keyboard go away when user click on background
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
}

// implement delegate extension so when return key is hit, will move to next keyboard or dismiss if it's the last keyboard
extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        guard let nextTextField = textField.superview?.viewWithTag(nextTag) else {
            textField.resignFirstResponder()
            return false
        }
        nextTextField.becomeFirstResponder()
        return false
    }
}

