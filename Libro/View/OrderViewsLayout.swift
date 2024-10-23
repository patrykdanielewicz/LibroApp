//
//  OrderViewsLayout.swift
//  Libro
//
//  Created by Patryk Danielewicz on 02/10/2024.
//

import UIKit

struct OrderViewsLayout {
    
    let kscameraButton       = CameraButton()
    let productTableView     = UITableView()
    let ksOrderTextField     = OrderTextField()
    let ksSendButton         = SendButton()
    let textFieldStackView   = UIStackView()
    let tableViewStackView   = UIStackView()
    
    
    func configureTableViewStackView() {
        view.addSubview(tableViewStackView)
        configureProductTableView()
        tableViewStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableViewStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableViewStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableViewStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableViewStackView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -60)])
        
        tableViewStackView.addArrangedSubview(productTableView)
    
        
    }
    
    func configureTextStackView() {
        view.addSubview(textFieldStackView)
        textFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        textFieldStackView.axis                                      = .horizontal
        textFieldStackView.distribution                              = .fillProportionally
        textFieldStackView.spacing                                   = 5
        
        NSLayoutConstraint.activate([
            textFieldStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            textFieldStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            textFieldStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            textFieldStackView.heightAnchor.constraint(equalToConstant: 44)])
        
        ksSendButton.imageView?.contentMode = .scaleAspectFit
        kscameraButton.imageView?.contentMode = .scaleAspectFit
        textFieldStackView.addArrangedSubview(kscameraButton)
        textFieldStackView.addArrangedSubview(ksOrderTextField)
        textFieldStackView.addArrangedSubview(ksSendButton)
    }
    
    
    func configureProductTableView() {
        productTableView.delegate                                  = self
        productTableView.dataSource                                = self
        productTableView.backgroundColor                           = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.00)
        productTableView.translatesAutoresizingMaskIntoConstraints = false
        productTableView.register(OrderCell.self, forCellReuseIdentifier: OrderCell.identifier)
        productTableView.separatorColor                            = UIColor(red: 0.93, green: 0.13, blue: 0.46, alpha: 1.00)
        productTableView.rowHeight                                 = UITableView.automaticDimension
        productTableView.estimatedRowHeight                        = 100
        
        
        view.keyboardLayoutGuide.followsUndockedKeyboard                                               = true
    }
    
    
    
    
    
}
