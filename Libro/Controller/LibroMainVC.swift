//
//  LibroMainVC.swift
//  Libro
//
//  Created by Patryk Danielewicz on 21.04.2024.
//

import UIKit

class LibroMainVC: UIViewController {

    let logoImageViev = UIImageView()
    let storeButtonKS = StoreButton(title: "Karwia Stara")
    let storeButtonKK = StoreButton(title: "Karwia Książki")
    let storeButtonKN = StoreButton(title: "Karwia Nowa")
    let storeButton0  = StoreButton(title: "Ostrowo")
    let storeButtonJG = StoreButton(title: "Jastrzębia Góra")
    let storeButtonCH  = StoreButton(title: "Chłapowo")
    let outOfStockButton = StoreButton(title: "Braki towaru")
    let stackViewTop = UIStackView()
    let stackViewMiddle = UIStackView()
    let stackViewBottom = UIStackView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       

        view.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.00)
        configureLogoImageViev()
        configureOutOfStockButton()
        configureStackViewTop()
        configureStackViewMiddle()
        configureStackViewBottom()
        storeButtonKS.addTarget(self, action: #selector(pushKarwiaStaraVC), for: .touchUpInside)
        storeButtonKK.addTarget(self, action: #selector (pushKarwiaKsiążkiVC), for: .touchUpInside)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
   
    @objc func pushKarwiaStaraVC() {
        navigationController?.pushViewController(KarwiaStaraVC(), animated: true)
    }
    
    @objc func pushKarwiaKsiążkiVC() {
        navigationController?.pushViewController(DefaultViewController(storeIndentifier: .karwiaKsiazki, orderStatus: .ordered), animated: true)
    }
    
    
    func configureStackViewTop() {
        view.addSubview(stackViewTop)
        stackViewTop.axis = .horizontal
        stackViewTop.distribution = .fillEqually
        stackViewTop.spacing = 30
        setStackViewTopConstrains()
        stackViewTop.addArrangedSubview(storeButtonKS)
        stackViewTop.addArrangedSubview(storeButtonKK)

    }
    
    func configureStackViewMiddle() {
        view.addSubview(stackViewMiddle)
        setStackViewMiddleConstrains()
        stackViewMiddle.axis = .horizontal
        stackViewMiddle.distribution = .fillEqually
        stackViewMiddle.spacing = 30
        stackViewMiddle.addArrangedSubview(storeButtonKN)
        stackViewMiddle.addArrangedSubview(storeButton0)
    }
    
    
    func configureStackViewBottom() {
        view.addSubview(stackViewBottom)
        setStackViewBottomConstrains()
        stackViewBottom.axis = .horizontal
        stackViewBottom.distribution = .fillEqually
        stackViewBottom.spacing = 30
        stackViewBottom.addArrangedSubview(storeButtonJG)
        stackViewBottom.addArrangedSubview(storeButtonCH)
    }
    
    func setStackViewBottomConstrains() {
        stackViewBottom.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackViewBottom.topAnchor.constraint(equalTo: stackViewMiddle.bottomAnchor, constant: 20),
            stackViewBottom.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackViewBottom.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            stackViewBottom.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    
    func setStackViewMiddleConstrains() {
        stackViewMiddle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackViewMiddle.topAnchor.constraint(equalTo: stackViewTop.bottomAnchor, constant: 20),
            stackViewMiddle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackViewMiddle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            stackViewMiddle.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
 
    
    
    func setStackViewTopConstrains() {
        stackViewTop.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackViewTop.topAnchor.constraint(equalTo: logoImageViev.bottomAnchor, constant: 50),
            stackViewTop.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackViewTop.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            stackViewTop.heightAnchor.constraint(equalToConstant: 100)
        ])
        
    }
    
    func configureLogoImageViev() {
        view.addSubview(logoImageViev)
        logoImageViev.translatesAutoresizingMaskIntoConstraints = false
        logoImageViev.image = UIImage(named: "Logo")!
        
        NSLayoutConstraint.activate([
        logoImageViev.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
        logoImageViev.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        logoImageViev.heightAnchor.constraint(equalToConstant: 120),
        logoImageViev.widthAnchor.constraint(equalToConstant: 300)
        ])
        
    }
   
    
    
    func configureStoreButtonKS() {
        view.addSubview(storeButtonKS)
        
        NSLayoutConstraint.activate([
            storeButtonKS.topAnchor.constraint(equalTo: logoImageViev.bottomAnchor, constant: 50),
            storeButtonKS.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            storeButtonKS.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -210),
            storeButtonKS.heightAnchor.constraint(equalToConstant: 100)
        ])
        
    }
        func configureStoreButtonKK() {
            view.addSubview(storeButtonKK)
            
            NSLayoutConstraint.activate([
                storeButtonKK.topAnchor.constraint(equalTo: logoImageViev.bottomAnchor, constant: 50),
                storeButtonKK.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 210),
                storeButtonKK.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
                storeButtonKK.heightAnchor.constraint(equalToConstant: 100)
            ])
        }
    
    
    func configureStoreButtonKN() {
        view.addSubview(storeButtonKN)
        
        NSLayoutConstraint.activate([
            storeButtonKN.topAnchor.constraint(equalTo: storeButtonKS.bottomAnchor, constant: 30),
            storeButtonKN.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            storeButtonKN.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -210),
            storeButtonKN.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    
    func configureStoreButtonO() {
        view.addSubview(storeButton0)
        
        
        NSLayoutConstraint.activate([
            storeButton0.topAnchor.constraint(equalTo: storeButtonKK.bottomAnchor, constant: 30),
            storeButton0.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 210),
            storeButton0.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            storeButton0.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    
    func configureStoreButtonJG() {
        view.addSubview(storeButtonJG)
        
        
        NSLayoutConstraint.activate([
            storeButtonJG.topAnchor.constraint(equalTo: storeButtonKN.bottomAnchor, constant: 30),
            storeButtonJG.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            storeButtonJG.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -210),
            storeButtonJG.heightAnchor.constraint(equalToConstant: 100)
        ])
        
    }
    
    
    
    func configureStoreButtonCH() {
        view.addSubview(storeButtonCH)
        
        
        NSLayoutConstraint.activate([
            storeButtonCH.topAnchor.constraint(equalTo: storeButton0.bottomAnchor, constant: 30),
            storeButtonCH.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 210),
            storeButtonCH.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            storeButtonCH.heightAnchor.constraint(equalToConstant: 100)])
    }
    
    
    func configureOutOfStockButton() {
        view.addSubview(outOfStockButton)
        
        
        NSLayoutConstraint.activate([
            outOfStockButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            outOfStockButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            outOfStockButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            outOfStockButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    }
    
