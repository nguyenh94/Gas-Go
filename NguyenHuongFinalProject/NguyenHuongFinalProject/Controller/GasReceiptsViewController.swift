//
//  GasStationsViewController.swift
//  NguyenHuongFinalProject
//
//  Created by Huong Nguyen on 4/7/22.
//  huongbng@usc.edu
//

import UIKit

class GasReceiptsViewController: UITableViewController {
    
    private var dataSource = ReceiptModel.sharedInstance
    private var gasBrandName: String?
    private var receiptDate: String?
    private var pricePerGallon: Float?
    private var totalPrice: Float?
    private var numberGallon: Float?
    
    // refresh the table when it appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
    }

    // set up cells for tableview
    // ask the datasource for a cell to insert in a particular location in tableview and here we have configured the cell that fits each receipt info 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create reusable cells
        let cell = tableView.dequeueReusableCell(withIdentifier: "receiptCell")!
        
        // modify the cell
        // get the receipt at each index for the corresponding row
        let receipt = dataSource.receipt(at: indexPath.row)
        // set the date to receipt date and total price as the main text
        cell.textLabel?.text = "$ " + String(format: "%.1f", (receipt?.getTotalPrice())!)
        cell.detailTextLabel?.text = receipt?.getDate()
        
        cell.editingAccessoryType = .detailButton

        return cell
    }
    
    // tap on details button would go to details page
    // delegate listen to see when the detail button is tapped for the row that user selected and send user to details page
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // retrieve the appropriate data for the selected cell to later pass onto detailReceipt segue
        self.gasBrandName = dataSource.receipt(at: indexPath.row)?.getGasBrand()
        self.receiptDate = dataSource.receipt(at: indexPath.row)?.getDate()
        self.pricePerGallon = dataSource.receipt(at: indexPath.row)?.getPricePerGallon()
        self.totalPrice = dataSource.receipt(at: indexPath.row)?.getTotalPrice()
        self.numberGallon = dataSource.receipt(at: indexPath.row)?.getGallons()
        
        // go to details screen
        performSegue(withIdentifier: "detailReceipt", sender: nil)
    }
        
    // return the number of rows -> all the receipts we have
    // tells the data source to return the number of rows in a given section of the table view, in this case all of our existing receipts
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfReceipts()
    }
    
    // edit the rows of table
    @IBAction func editDidTapped(_ sender: UIBarButtonItem) {
        // toggle edit button between editing mode and finished editing mode
        if tableView.isEditing {
            tableView.isEditing = false
            sender.title = "Edit"
        } else {
            tableView.isEditing = true
            sender.title = "Done"
        }
    }
    
    // remove receipt when user edit and delete
    // the delegate listens to which row user is on and perform appropriate action when user edit the row
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // User wants to delete
        if editingStyle == .delete {
            // delete data from cloud
            dataSource.deleteData(receipts: &dataSource.receipts, at: indexPath.row)
            //remove the data from the model
            dataSource.removeReceipt(at: indexPath.row)
            
            // Do a fancy fade out animation to remove the cell
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // make sure table cell is not selectable
    // tells the deleagte which row is selected and deselect that selected row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // send data over to details view controller to later load when user select it
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailViewController = segue.destination as? DetailsViewController {
            detailViewController.gasBrandName = gasBrandName
            detailViewController.receiptDate = receiptDate
            detailViewController.pricePerGallon = pricePerGallon
            detailViewController.totalPrice = totalPrice
            detailViewController.numberGallon = numberGallon
        }
    }
}
