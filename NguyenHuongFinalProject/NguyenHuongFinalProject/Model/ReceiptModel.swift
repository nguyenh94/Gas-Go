//
//  ReceiptModel.swift
//  NguyenHuongFinalProject
//
//  Created by Huong Nguyen on 4/25/22.
//  huongbng@usc.edu
//

import Foundation
import UIKit
import Firebase

class ReceiptModel: NSObject, ReceiptDataModel {
    //singleton (invoking default initializer). Use singlaton as datasource for modification
    static let sharedInstance = ReceiptModel()
    
    // have an array to store receipts
    var receipts: [Receipt] = [Receipt]()
    
    // date formatter to convert date to string and format properly
    let dateFormatter = DateFormatter()
    
    // initializer
    override init() {
        super.init()
        dateFormatter.dateFormat = "MM/dd/YY"
        // load data from firestore if already exists
        loadData(receipts: &receipts)
    }
    
    // load data from firestore if there is existing data for each logged in user
    func loadData(receipts: inout [Receipt]) -> Void {
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document("\(userId)").collection("receipts").order(by: "index").getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in snapshot!.documents {
                        let dataDictionary = document.data()
                        var date: String = ""
                        var pricePerGallon: Float = 0.0
                        var totalPrice: Float = 0.0
                        var gallons: Float = 0.0
                        var gasBrand: String = ""
                        var documentKey: String = ""
                        if let dateUnwrap = dataDictionary["date"] as? String, let pricePerGallonUnwrap = dataDictionary["pricePerGallon"] as? String, let totalPriceUnwrap = dataDictionary["totalPrice"] as? Float, let gallonsUnwrap = dataDictionary["numberGallons"] as? Float, let gasBrandUnwrap = dataDictionary["gasBrand"] as? String, let keyUnwrap = dataDictionary["documentKey"] as? String {
                            date = dateUnwrap
                            pricePerGallon = Float(pricePerGallonUnwrap)!
                            print(pricePerGallon)
                            totalPrice = totalPriceUnwrap
                            gallons = gallonsUnwrap
                            gasBrand = gasBrandUnwrap
                            documentKey = keyUnwrap
                            self.receipts.append(Receipt(date: date, pricePerGallon: pricePerGallon, totalPrice: totalPrice, gallons: gallons, gasBrand: gasBrand, key: documentKey))
                        }
                    }
                }
            }
        }
    }
    
    // save/update data to database
    func deleteData(receipts: inout [Receipt], at index: Int) -> Void {
        // use setData to overwrite the whole document
        let userId = Auth.auth().currentUser!.uid
        let documentKey = receipts[index].getKey()
        Firestore.firestore().collection("users").document("\(userId)").collection("receipts").document("\(documentKey)").delete()
    }

    // function to determine how many receipts are there
    func numberOfReceipts() -> Int {
        return receipts.count
    }
    
    // get the receipt at the selected index
    func receipt(at index: Int) -> Receipt? {
        //what happen if index is out of bound? return nil
        // check with if else logic for out of bound
        if index >= 0 && index < receipts.count {
            return receipts[index]
        } else {
            return nil
        }
    }
    
    // function to insert receipt at the end of the array (so latest added receipt will be at the bottom)
    func insert(date: String,
                pricePerGallon: Float,
                totalPrice: Float, gallons: Float, gasBrand: String, key: String) {
        receipts.append(Receipt(date: date, pricePerGallon: pricePerGallon, totalPrice: totalPrice, gallons: gallons, gasBrand: gasBrand, key: key))
    }
    
    // function to remove/delete a receipt
    func removeReceipt(at index: Int) {
        if index >= 0 && index < receipts.count { // make sure index to remove exists
            receipts.remove(at: index)
        }
    }
    
    // reinitialize whenever log out and log in with another user credentials
    func reinitializeModel() {
        receipts = [Receipt]()
        dateFormatter.dateFormat = "MM/dd/YY"
        // load data from firestore if already exists
        loadData(receipts: &receipts)
    }
}
