//
//  SignUpViewController.swift
//  NguyenHuongFinalProject
//
//  Created by Huong Nguyen on 4/27/22.
//  huongbng@usc.edu
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var dataSource = ReceiptModel.sharedInstance
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var carModelTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        welcomeLabel.text = String(format: NSLocalizedString("Welcome to Gas$Go!", comment: ""))
        signUpButton.setTitle(NSLocalizedString("Sign Up", comment: ""), for: .normal)
        signInButton.setTitle(NSLocalizedString("Already a user? Login", comment: ""), for: .normal)
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageTap)
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        // give tag to text field so can go through all text fields and dismiss keyboard when return key is tapped
        usernameTextField.tag = 0
        usernameTextField.delegate = self
        carModelTextField.tag = 1
        carModelTextField.delegate = self
        emailTextField.tag = 2
        emailTextField.delegate = self
        passwordTextField.tag = 3
        passwordTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // clear all fields
        profileImageView.image = UIImage(systemName: "person.crop.circle.badge.plus")
        usernameTextField.text = ""
        carModelTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageTap)
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }
    

    // open image picker
    @objc func openImagePicker(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //hitting done will dismiss text field
    @IBAction func userNameField(_ sender: UITextField) {
        usernameTextField.resignFirstResponder()
    }
    
    
    
    // create user authentication in firebase
    @IBAction func signUpDidTapped(_ sender: UIButton) {
        // Validation
        // Regular expression to do validation on strings (ex: check if email is valid email like regrex) - a way to write a pattern and check against that pattern
        // can do restrictions/requirements on password here
        let username = usernameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let carModel = carModelTextField.text!
        let image = profileImageView.image!
        
        // return if any of the text fields is empty
        if email.isEmpty || password.isEmpty || carModel.isEmpty || username.isEmpty {
            return
        }
        
        // authorize and create account with firebase auth. Simple check for valid email and password done by firebase
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error{ // if there is an error, just print the error and don't do anything else
                print(error)
                return
            }
            // successful sign up
            // closure executes first, whatever outside executes second, and whatever inside it executes last
            if let userId = authResult?.user.uid {
                print("User has successfully signed up \(userId)")
                //reinitialize data in the case of just logged out
                
                // 1. Upload the profile image to Firebase Storage
                // create a reference -> store image under userid
                let storageRef = Storage.storage().reference().child("user/\(userId).png")
                
                // convert image into data format
                guard let imageData = image.pngData() else {return}
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                
                // upload image onto storage
                storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                    if let error = error {
                        print("Error \(error)")
                        return
                    }
                    // create path for each image in storage
                    storageRef.downloadURL { url, error in
                        if let error = error {
                            print("Error: \(error)")
                        } else {
                            let downloadURL = url
                            changeRequest?.photoURL = downloadURL  // save the image URL as the photoURL for each registered user
                            changeRequest?.commitChanges { error in
                                if error == nil { // update username
                                    print("User display name changed!")
                                } else { // error
                                    print("Error: \(error!.localizedDescription)")
                                }
                                // create firestore to store additional property such as car model
                                let ref1 = Firestore.firestore().collection("users").document("\(userId)")
                                ref1.setData([
                                    "userName": "\(String(describing: Auth.auth().currentUser!.displayName))", //unwrap
                                    "carModel": "\(carModel)",
                                    "imageURL": "\(downloadURL!)"
                                ])
                                
                                // execute in the main thread
                                DispatchQueue.main.async {
                                    // clear all fields and reset image view to default
                                    self?.profileImageView.image = UIImage(systemName: "person.crop.circle.badge.plus")
                                    self?.usernameTextField.text = ""
                                    self?.carModelTextField.text = ""
                                    self?.emailTextField.text = ""
                                    self?.passwordTextField.text = ""
                                    
                                    // reinitialize receipt model if necessary
                                    self?.dataSource.reinitializeModel()
                                    
                                    // If successful, take user to home screen
                                    self!.performSegue(withIdentifier: "profileSegue1", sender: nil) // show the home screen
                                }
                            } // commitChanges closure
                        }
                    }
                }
                changeRequest?.displayName = self?.usernameTextField.text! //set username to display name
            } // end of authenticating userid
        } // end of createUser
    } // end of signUpDidTapped
    
    // take user to login in page
    @IBAction func loginDidTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "signInSegue", sender: nil)
    }
    
    // if user cancels -> dismiss image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // if user chose an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // get the image user selected
        // use editedimage since we allow editing of photo chosen
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] {
            self.profileImageView.image = (pickedImage as! UIImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
        
    // make keyboard go away when user click on background
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
}

// extension to go from one keyboard to the next and dismiss if it's the last keyboard when user hits return 
extension SignUpViewController: UITextFieldDelegate {
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
