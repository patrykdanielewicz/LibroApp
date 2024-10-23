//
//  OrderTextField.swift
//  Libro
//
//  Created by Patryk Danielewicz on 22.04.2024.
//

import UIKit

class OrderTextField: UITextField {
    
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }
        
        override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }
        
        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }
    

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.93, green: 0.13, blue: 0.46, alpha: 1.00).cgColor
        
        textColor = .black
        tintColor = .black
        textAlignment = .natural
        font = UIFont.preferredFont(forTextStyle: .title2)
        
        backgroundColor = .white
        autocorrectionType = .default
        minimumFontSize = 10
        adjustsFontSizeToFitWidth = false
        
        let placeholderText = ConstantValuesAndNames.placeholderText
        let placeholderColor = UIColor.darkGray
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeholderColor]
        attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        
        
        
    }
}
