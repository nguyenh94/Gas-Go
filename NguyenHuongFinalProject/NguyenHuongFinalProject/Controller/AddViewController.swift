//
//  AddViewController.swift
//  NguyenHuongFinalProject
//
//  Created by Huong Nguyen on 4/18/22.
//  huongbng@usc.edu
//

import UIKit
import Firebase

class AddViewController: UIViewController {
    private var dataSource: ReceiptModel!
    private var totalPrice: Float = 0.0
    private var numberOfGallons: Float = 10.0
    private var userId: String = ""

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var gasBrandTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var gallonSlider: UISlider!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var gallonsLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        brandLabel.text = String(NSLocalizedString("Brand", comment: ""))
        priceLabel.text = String(NSLocalizedString("Price", comment: ""))
        userId = Auth.auth().currentUser!.uid
        dataSource = ReceiptModel.sharedInstance
        saveButton.isEnabled = false
        datePicker.date = Date() //set calender to current date
        
        // initialize text fields to delegate and set tag to be used for delegate and jump to next keyboard once hit return
        gasBrandTextField.tag = 0
        gasBrandTextField.delegate = self
        priceTextField.tag = 1
        priceTextField.delegate = self
    }
    
    // fired whenever text field changes in brand text field
    @IBAction func gasBrandDidTyped(_ sender: UITextField) {
        checkSave()
    }
        
    // fired whenever text field changes in price text field (check if all info is input to enable save button)
    @IBAction func priceDidTyped(_ sender: UITextField) {
        checkSave()
    }

    
    // update amount of gallon label accordingly when user changes slider
    @IBAction func sliderDidChange(_ sender: UISlider) {
        let gallonAmount = Float(sender.value)
        
        // round number of gallons down to 1 decimal place
        gallonsLabel.text = String(format: "%.1f", gallonAmount) + " gallons"
    }
    
    // clear fields, reset slider, reset picker to current date
    @IBAction func cancelButtonDidTapped(_ sender: UIBarButtonItem) {
        // clear text fields
        gasBrandTextField.text! = ""
        priceTextField.text! = ""
        
        // disable save button
        saveButton.isEnabled = false
        
        // reset date to current date
        datePicker.date = Date()
        
        // reset gallon slider to initial value of 10.0
        gallonSlider.value = numberOfGallons
        
        // dismiss keyboard
        if gasBrandTextField.isFirstResponder {
            gasBrandTextField.resignFirstResponder()
        } else if priceTextField.isFirstResponder {
            priceTextField.resignFirstResponder()
        }
        self.dismiss(animated: true, completion: {})  // dismiss add screen
    }
    
    // when user click on save button
    @IBAction func saveButtonDidTapped(_ sender: UIBarButtonItem) {
        // calculate the total price
        totalPriceCal(&totalPrice, pricePerGallon: Float(priceTextField.text!)!, gallons: gallonSlider.value)
        
        // check if all fields have been filled out
        checkSave()
        
        // store data onto Firestore
        let date = dataSource.dateFormatter.string(from: datePicker.date)
        
        // create timestamp to order by first created to last created
        // create a new date collection each for each table entry
        // add data to store in firestore 
        let rootCollection = Firestore.firestore().collection("users").document("\(userId)").collection("receipts")
        let newCollection = rootCollection.addDocument(data: [:])
        newCollection.setData([
            "date": date,
            "gasBrand": gasBrandTextField.text!,
            "totalPrice": totalPrice,
            "pricePerGallon": priceTextField.text!,
            "numberGallons": gallonSlider.value,
            "documentKey": newCollection.documentID,
            "index": dataSource.numberOfReceipts()
        ])
        
        // insert receipt into receipt array
        dataSource.insert(date: dataSource.dateFormatter.string(from: datePicker.date), pricePerGallon: Float(priceTextField.text!)!, totalPrice: totalPrice, gallons: gallonSlider.value, gasBrand: gasBrandTextField.text!, key: newCollection.documentID)
                
        // dismiss the keyboard
        gasBrandTextField.resignFirstResponder()
        priceTextField.resignFirstResponder()
        
        // dismiss the view
        self.dismiss(animated: true, completion: {})
    }
    
    // helper method to enable/disable save button when editing
    func checkSave() {
        //enable save button only when there is text both in textview and textfield
        if !gasBrandTextField.text!.isEmpty && !priceTextField.text!.isEmpty {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    // calculate the total gas price
    func totalPriceCal(_ totalPrice: inout Float, pricePerGallon: Float, gallons: Float) -> Void {
        totalPrice = pricePerGallon * gallons
    }
    
    // make keyboard go away when user click on background
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }

}

// implement delegate extension so when return key is hit, will move to next keyboard or dismiss if it's the last keyboard
extension AddViewController: UITextFieldDelegate {
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
