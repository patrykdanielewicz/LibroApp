//
//  SendButton.swift
//  Libro
//
//  Created by Patryk Danielewicz on 01.05.2024.
//

import UIKit

class SendButton: UIButton {
    
    override init(frame: CGRect) {
           super.init(frame: frame)
        configureSendButton()
       }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureSendButton() {
        translatesAutoresizingMaskIntoConstraints = false
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium, scale: .default)
        let image = UIImage(systemName: "paperplane.circle", withConfiguration: symbolConfig)
       
      
        setImage(image, for: .normal)
        tintColor = UIColor(red: 0.93, green: 0.13, blue: 0.46, alpha: 1.00)
        
    }
}
