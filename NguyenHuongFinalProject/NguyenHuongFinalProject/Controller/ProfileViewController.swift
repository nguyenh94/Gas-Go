//
//  ProfileViewController.swift
//  NguyenHuongFinalProject
//
//  Created by Huong Nguyen on 4/27/22.
//  huongbng@usc.edu
//

import UIKit
import Firebase
import FirebaseStorage
import WebKit

class ProfileViewController: UIViewController, WKNavigationDelegate {

    private var dataSource = ReceiptModel.sharedInstance
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var carModelLabel: UILabel!
    @IBOutlet weak var webView: WKWebView!
    
    var imageUrl: URL!
    
    override func viewWillAppear(_ animated: Bool) {
        webView.navigationDelegate = self
        signOutButton.setTitle(NSLocalizedString("Sign Out", comment: ""), for: .normal)
        usernameLabel.text = Auth.auth().currentUser?.displayName
        emailLabel.text = Auth.auth().currentUser?.email
        let userId = Auth.auth().currentUser!.uid
                
        // read in data from Firestore to get Car Model
        Firestore.firestore().collection("users").document("\(userId)").getDocument { snap, err in
            if let err = err {
                print("there is an error \(err.localizedDescription)")
                return // if there's an error, no need to go further so just return
            }
            
            if let data = snap?.data() { // do optional unwrapping cause everytime get a value out of a dictionary, it'll be an optional version
                let carModel = data["carModel"]!
                self.imageUrl = URL(string: data["imageURL"] as! String)
                // this will make sure we are on the main thread when executing these tasks
                DispatchQueue.main.async {
                    // update the IBoutlets everytime data changes in database
                    self.carModelLabel.text = carModel as? String
                    // create a URLRequest to load image with webview
                    if let url = self.imageUrl {
                        let request = URLRequest(url: url)
                        self.webView.load(request) //load the webview
                    } else {
                        print("Error loading image")
                    }
                }
            }
        }
    }
    
    // initially load the view
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        signOutButton.setTitle(NSLocalizedString("Sign Out", comment: ""), for: .normal)
        usernameLabel.text = Auth.auth().currentUser?.displayName
        emailLabel.text = Auth.auth().currentUser?.email
        let userId = Auth.auth().currentUser!.uid
                
        // read in data from Firestore to get Car Model
        Firestore.firestore().collection("users").document("\(userId)").getDocument { snap, err in
            if let err = err {
                print("there is an error \(err.localizedDescription)")
                return // if there's an error, no need to go further so just return
            }
            
            // get data from firestore
            if let data = snap?.data() { // do optional unwrapping cause everytime get a value out of a dictionary, it'll be an optional version
                let carModel = data["carModel"]!
                self.imageUrl = URL(string: data["imageURL"] as! String)
                // this will make sure we are on the main thread when executing these taks
                DispatchQueue.main.async {
                    // update the IBoutlets everytime data changes in database
                    self.carModelLabel.text = carModel as? String
                    // create a URLRequest
                    if let url = self.imageUrl {
                        let request = URLRequest(url: url)
                        self.webView.load(request) //load the webview
                    } else {
                        print("Error loading image")
                    }
                }
            }
        }
    }
    
    // sign user out when tap sign out button
    @IBAction func signOutDidTapped(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
