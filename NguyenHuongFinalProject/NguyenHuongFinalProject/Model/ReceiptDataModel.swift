//
//  ReceiptDataModel.swift
//  NguyenHuongFinalProject
//
//  Created by Huong Nguyen on 4/25/22.
//  huongbng@usc.edu
//

import Foundation

protocol ReceiptDataModel {
    
    // function to determine how many receipts are there
    func numberOfReceipts() -> Int
    
    // get the receipt at each index for each row in the tableview
    func receipt(at index: Int) -> Receipt?
    
    // function to insert receipt at the end
    func insert(date: String,
                pricePerGallon: Float,
                totalPrice: Float, gallons: Float, gasBrand: String, key: String)
    
    // function to remove/delete a receipt
    func removeReceipt(at index: Int)
}
