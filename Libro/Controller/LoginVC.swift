//
//  LoginVC.swift
//  Libro
//
//  Created by Patryk Danielewicz on 17.06.2024.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginVC: UIViewController {

    let logoImageView       = UIImageView()
    let loginButton         = StoreButton(title: "ZALOGUJ")
    let registerButton      = StoreButton(title: "ZAREJESTRUJ")
    let loginButtonSV       = UIStackView()
    let loginTextFieldSV    = UIStackView()
    let loginTextField      = OrderTextField()
    let passwordTextField   = OrderTextField()
    var usherData           = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.00)
        loginTextField.delegate = self
        passwordTextField.delegate = self
        loginTextFieldConfig()
        configureLoginTextFieldSV()
        configureLoginButtonSV()
        configureLogoImageViev()
        loginButton.addTarget(self, action: #selector(logInButtonPressed), for: .touchUpInside)
        
        if let userDataFilePath = Bundle.main.path(forResource: "userData", ofType: "txt") {
            if let userRawData = try? String(contentsOfFile: userDataFilePath) {
                usherData = userRawData.components(separatedBy: "\n")
                loginTextField.text = usherData[0]
                passwordTextField.text = usherData[1]
            }
            else {
                loginTextField.text = ""
                passwordTextField.text = ""
            }
        }
            
            
        
        
        
        
        
        
    }
    
    @objc func logInButtonPressed() {
     
        if let email = loginTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                }
                else {
                    self.navigationController?.pushViewController(LibroMainVC(), animated: true)

                }
            }
            
        }
        
    }
    
    func configureLogoImageViev() {
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage(named: "Logo")
        
        NSLayoutConstraint.activate([
        logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        logoImageView.heightAnchor.constraint(equalToConstant: 120),
        logoImageView.widthAnchor.constraint(equalToConstant: 300)
        ])
        
    }
    
    func loginTextFieldConfig() {
        loginTextField.placeholder = "Wpisz login"
        loginTextField.autocapitalizationType = .none
        passwordTextField.placeholder = "Wpisz hasło"
        passwordTextField.autocapitalizationType = .none
        passwordTextField.isSecureTextEntry = true
    }

    func configureLoginTextFieldSV() {
        view.addSubview(loginTextFieldSV)
        loginTextFieldSV.axis = .vertical
        loginTextFieldSV.distribution = .fillEqually
        loginTextFieldSV.spacing = 30
        loginTextFieldSV.addArrangedSubview(loginTextField)
        loginTextFieldSV.addArrangedSubview(passwordTextField)
        
        loginTextFieldSV.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loginTextFieldSV.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 250),
            loginTextFieldSV.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            loginTextFieldSV.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            loginTextFieldSV.heightAnchor.constraint(equalToConstant: 130)
        ])
    }
        
    func configureLoginButtonSV() {
        view.addSubview(loginButtonSV)
        loginButtonSV.axis = .vertical
        loginButtonSV.distribution = .fillEqually
        loginButtonSV.spacing = 30
        loginButtonSV.addArrangedSubview(loginButton)
        loginButtonSV.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loginButtonSV.topAnchor.constraint(equalTo: loginTextFieldSV.bottomAnchor, constant: 50),
            loginButtonSV.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            loginButtonSV.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            loginButtonSV.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
        
    

}




extension LoginVC: UITextFieldDelegate {
    
}
