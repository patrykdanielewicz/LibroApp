//
//  ConstatnValues&Names.swift
//  Libro
//
//  Created by Patryk Danielewicz on 03/10/2024.
//

import UIKit

enum AddNewCellArguments {
    case row(Int)
    case cell(OrderCell)
    case new
}

enum StoreIndentifier: String {
    
    case karwiaStara
    case karwiaNowa
    case karwiaKsiazki
    case ostrowo
    case rybacka
    case chlapowo
}

enum OrderStatus: String {
    
    case ordered
    case prepared
}

enum CloudDictionaryKeys {
    
     static let date = "Date"
     static let order = "Order"
    
}


struct ConstantValuesAndNames {
    
    static let secondColor = UIColor(red: 0.93, green: 0.13, blue: 0.46, alpha: 1.00)
    static let placeholderText = "Wpisz zamawiany produkt"
    
    let sendButtonImage = "arrow.up.circle.fill"
    static let cameraButtonImage = "camera.circle.fill"
    static let cellIdentifier = "OrderCell"
       
    func getStoreName(formStoreIndentifier identifier: StoreIndentifier) -> String {
        let storeName = identifier.rawValue.unicodeScalars.reduce("") { (whatDone, whatLeft) in
            if CharacterSet.uppercaseLetters.contains(whatLeft) {
                return whatDone + " " + String(whatLeft)
            }
            else {
                return whatDone + String(whatLeft)
            }
        }
        return storeName.capitalized
    }
   
    
}

