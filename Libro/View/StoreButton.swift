//
//  StoreButton.swift
//  Libro
//
//  Created by Patryk Danielewicz on 22.04.2024.
//

import UIKit

class StoreButton: UIButton {

    override init(frame: CGRect) {
           super.init(frame: frame)
        configure()
       }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(title: String) {
        super.init(frame: .zero)
        self.setTitle(title, for: .normal)
        configure()
        
    }
    private func configure() {
        
        
        backgroundColor = .white
        setTitleColor(UIColor(red: 0.93, green: 0.13, blue: 0.46, alpha: 1.00), for: .normal)
        
        titleLabel?.textAlignment = .center
    
    titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        layer.cornerRadius = 10
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowColor = UIColor(red: 0.79, green: 0.83, blue: 1.00, alpha: 1.00).cgColor
        layer.cornerRadius = 10
        translatesAutoresizingMaskIntoConstraints = false
    
        
        
    }
    
    
}
//UIColor(red: 0.93, green: 0.13, blue: 0.46, alpha: 1.00)
