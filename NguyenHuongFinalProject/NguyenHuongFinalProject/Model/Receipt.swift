//
//  Receipt.swift
//  NguyenHuongFinalProject
//
//  Created by Huong Nguyen on 4/18/22.
//  huongbng@usc.edu
//

import Foundation

struct Receipt: Equatable, Codable {
    private var date: String
    private var pricePerGallon: Float
    private var totalPrice: Float
    private var gallons: Float
    private var gasBrand: String
    private var key: String
    
    func getKey() -> String {
        return key
    }
    
    func getDate() -> String {
        return date
    }
    
    func getPricePerGallon() -> Float {
        return pricePerGallon
    }
    
    func getTotalPrice() -> Float {
        return totalPrice
    }
    
    func getGallons() -> Float {
        return gallons
    }
    
    func getGasBrand() -> String {
        return gasBrand
    }
    
    init(date: String, pricePerGallon: Float, totalPrice: Float, gallons: Float, gasBrand: String, key: String){
        self.date = date
        self.pricePerGallon = pricePerGallon
        self.totalPrice = totalPrice
        self.gallons = gallons
        self.gasBrand = gasBrand
        self.key = key
    }
}
