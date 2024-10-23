//
//  PreparedKarwiaStaraVC.swift
//  Libro
//
//  Created by Patryk Danielewicz on 10.05.2024.
//

import UIKit
import Firebase

class PreparedKarwiaStaraVC: UIViewController {
    
    let db                       = Firestore.firestore()
    let preparedTableView        = UITableView()
    var preparedArray : [String] = []
    var docIDArray: [String]     = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.00)
        title                = "Przygotowane Karwia Stara"
        
        configureTableView()
        readDataFromCloud()
        preparedTableView.allowsMultipleSelection = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        readDataFromCloud()
    }
    
    func readDataFromCloud() {
        db.collection("KarwiaStaraPrepared").order(by: "date").addSnapshotListener { querySnapshot, error in
            self.preparedArray = []
            self.docIDArray    = []
            
            if let e = error {
              print(e)
                }
            else {
               
                if let snapshotDocument = querySnapshot?.documents {
                 
                    for doc in snapshotDocument {
                      
                        let data = doc.data()
                        
                        if let newPreparedItem = data["prepared"] as? String {
                            self.preparedArray.append(newPreparedItem)
                            self.docIDArray.append(doc.documentID)
                        
                        
                            DispatchQueue.main.async {
                                self.preparedTableView.reloadData()
                            }
                        }
                     
                    }
                }
            }
        }
        
    }
    
    
    func configureTableView() {
        view.addSubview(preparedTableView)
        preparedTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
        preparedTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
        preparedTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
        preparedTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
        preparedTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        
        preparedTableView.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.00)
        
        preparedTableView.delegate = self
        preparedTableView.dataSource = self
        
        preparedTableView.register(OrderCell.self, forCellReuseIdentifier: "orderCell")
        preparedTableView.separatorColor = UIColor(red: 0.93, green: 0.13, blue: 0.46, alpha: 1.00)
    }
    
    
    
    
}

extension PreparedKarwiaStaraVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preparedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = preparedTableView.dequeueReusableCell(withIdentifier: "orderCell") as! OrderCell
        var content = cell.defaultContentConfiguration()
        content.text = preparedArray[indexPath.row]
        content.textProperties.color = .black
        
        cell.contentConfiguration = content 
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delate = UIContextualAction(style: .destructive, title: "Na punkcie") { action, view, completionHendler in
            
            self.db.collection("KarwiaStaraPrepared").document(self.docIDArray[indexPath.row]).delete { error in
                if error != nil {
                    print("Problem przy kasowaniu danych z kolekcji KarwiaStaraPrepared")
                }
            }
            
            self.preparedArray.remove(at: indexPath.row)
            self.docIDArray.remove(at: indexPath.row)
            self.preparedTableView.deleteRows(at: [indexPath], with: .automatic)
            
            completionHendler(true)
        
            
        }
        let configuration =  UISwipeActionsConfiguration(actions: [delate])
        return configuration
    }
    
    
    
}
