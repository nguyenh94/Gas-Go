//
//  DetailsViewController.swift
//  NguyenHuongFinalProject
//
//  Created by Huong Nguyen on 4/20/22.
//  huongbng@usc.edu
//

import UIKit

class DetailsViewController: UIViewController {
    private var dataSource = ReceiptModel.sharedInstance
    
    // add variable here for data that wants to be passed such as Gas Brand lable, Date label, total price label, etc.
    var gasBrandName: String!
    var receiptDate: String!
    var totalPrice: Float!
    var pricePerGallon: Float!
    var numberGallon: Float!
    
    // Then use prepared statement from HW7 to connect data
    // segue is a view controller 
    
    @IBOutlet weak var totalPriceTitle: UILabel!
    @IBOutlet weak var numberGallonTitle: UILabel!
    @IBOutlet weak var pricePerGallonTitle: UILabel!
    @IBOutlet weak var gasBrandLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var pricePerGallonLabel: UILabel!
    @IBOutlet weak var numberGallonLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // load the view with all information user added
        totalPriceTitle.text = String(NSLocalizedString("Total price", comment: ""))
        pricePerGallonTitle.text = String(NSLocalizedString("Price per gallon", comment: ""))
        numberGallonTitle.text = String(NSLocalizedString("Number of gallons", comment: ""))
        gasBrandLabel.text = gasBrandName
        dateLabel.text = receiptDate
        totalPriceLabel.text = "$ " + String(format: "%.1f", totalPrice)  // round down to 1 decimal place
        pricePerGallonLabel.text = "$ " + String(format: "%.1f", pricePerGallon)  // round down to 1 decimal place
        numberGallonLabel.text = String(format: "%.1f", numberGallon)
    }
    
}
