//
//  KarwiaStaraVC.swift
//  Libro
//
//  Created by Patryk Danielewicz on 01.05.2024.
//

import UIKit
import Firebase
import FirebaseStorage
import Kingfisher


class KarwiaStaraVC: UIViewController {
    
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    let metadata = StorageMetadata()
//    let imageView: UIImageView
    
    let kscameraButton       = CameraButton()
    let productTableView     = UITableView()
    let ksOrderTextField     = OrderTextField()
    let ksSendButton         = SendButton()
    let textFieldStackView   = UIStackView()
    let tableViewStackView   = UIStackView()
    var imageDictionnaris    = [String: UIImage]()
    var orderArray: [String] = [] {
        didSet {
            let addedItems = orderArray.filter { item in
                !oldValue.contains(item)
            }
//            let removedItems = oldValue.filter { item in
//                !orderArray.contains(item)
//            }
            if !addedItems.isEmpty {
                for item in addedItems {
                    let isURL = item.contains("https")
                    if isURL {
                        if let url = URL(string: item) {
                            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                                
                                if let data = data, error == nil {
                                    if let image = UIImage(data: data) {
                                        DispatchQueue.main.async {
                                            self.imageDictionnaris[item] = image
                                            self.productTableView.reloadData()
                                        }
                                    }
                                    else {
                                        print("Something went wrong with changing data on UIImage")
                                    }
                                }
                                else {
                                    print("Something went wrong with downloading pictures (as data)")
                                }
                            }
                            task.resume()
                        }
                        else {
                            print("tutaj jest kurwa coś nie takk")
                        }
                    }
                }
                productTableView.reloadData()
            }
            
        }
    }
    var docIDArray: [String] = []
    var docRef: DocumentReference!
    var urlArray: [String] = []
    var ipath: IndexPath?
    var indexPathforActiveTextField: IndexPath? {
        didSet{
            ipath = oldValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.00)
        title                = "Karwia Stara"
        
        
        customizeNavigationBarTitle(for: self.navigationController!)
        configureTableViewStackView()
        keyboardSetup ()
        ksOrderTextField.delegate = self
        ksSendButtonTarget()
        readDataFromCloud()
        ksCameraButtonTarget()
        
        view.keyboardLayoutGuide.followsUndockedKeyboard = true
      
    }
    
  
    func ksSendButtonTarget() {
        ksSendButton.addTarget(self, action: #selector(passingDataToCloud), for: .touchUpInside)
    }
    
    func ksCameraButtonTarget() {
        kscameraButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        
    }
    
    
    
    
    @objc func passingDataToCloud() {
        if let orderText = ksOrderTextField.text {
            db.collection("KarwiaStaraOrder").addDocument(data: [
                "Order": orderText,
                "Date": Date().timeIntervalSince1970,
            ]) { error in
                if error != nil {
                    print("problem z przesłaniem danych")
                }
                else {
                    self.ksOrderTextField.text = ""
                }
            }
        }
        
    }
    
    
    func readDataFromCloud() {
        db.collection("KarwiaStaraOrder").order(by: "Date").addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                  print("Error fetching snapshots: \(error!)")
                  return
                }
                snapshot.documentChanges.forEach { diff in
                  if diff.type == .added {
                      let data = diff.document.data()
                      if let newOrder = data["Order"] as? String {
                          self.orderArray.append(newOrder)
                          self.docIDArray.append(diff.document.documentID)
                      }
                  }
                  if (diff.type == .modified) {
                      
                  }
                  if (diff.type == .removed) {
                  }
                }
              
//            if let e = error {
//                print("the was an issue retreving data from Firebase \(e)")
//            }
//            else {
//                if let snapshotDocuments = querySnapshot?.documents {
//                    
//                    for doc in snapshotDocuments {
//                        let data = doc.data()
//                        if let newOrder = data["Order"] as? String, let newURL = data["Pictures"] as? String {
//                            
//                            self.orderArray.append(newOrder)
//                            self.docIDArray.append(doc.documentID)
//                            self.urlArray.append(newURL)
//                            
////                            DispatchQueue.main.async {
////                                self.productTableView.reloadData()
////                            }
//                        }
//                    }
//                }
//                if let anyChanges = querySnapshot?.documentChanges {
//                    switch anyChanges.type {
//                        
//                    }
//                }
//            }

        }
    }
    

    
    func configureTableViewStackView() {
        view.addSubview(tableViewStackView)
        
        configureProductTableView()
        configureTextStackView()
        
        tableViewStackView.distribution = .fill
        tableViewStackView.axis = .vertical
        tableViewStackView.spacing = 10
        tableViewStackView.translatesAutoresizingMaskIntoConstraints = false
        tableViewStackView.addArrangedSubview(productTableView)
        tableViewStackView.addArrangedSubview(textFieldStackView)
        
        NSLayoutConstraint.activate([
            tableViewStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableViewStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableViewStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableViewStackView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10),
            
            textFieldStackView.bottomAnchor.constraint(equalTo: tableViewStackView.bottomAnchor),
            textFieldStackView.heightAnchor.constraint(equalToConstant: 44)])
    }
    
    func configureTextStackView() {
        textFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        textFieldStackView.axis                                      = .horizontal
        textFieldStackView.distribution                              = .fillProportionally
        textFieldStackView.spacing                                   = 5
    
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
        productTableView.register(OrderCell.self, forCellReuseIdentifier: ConstantValuesAndNames.cellIdentifier)
        productTableView.separatorColor                            = UIColor(red: 0.93, green: 0.13, blue: 0.46, alpha: 1.00)
//        productTableView.rowHeight                                 = UITableView.automaticDimension
//        productTableView.estimatedRowHeight                        = 100
        
        
        
    }
    
    func customizeNavigationBarTitle(for navigationController: UINavigationController) {
       let appearance = UINavigationBarAppearance()
        navigationController.setNavigationBarHidden(false, animated: true)
        appearance.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.0)
        appearance.shadowColor = .none
       
       
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
            .foregroundColor: UIColor(red: 0.93, green: 0.13, blue: 0.46, alpha: 1.00) ]
    
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        
        let preparedButton = UIBarButtonItem(image: UIImage(systemName: "tray.full.fill"), style: .plain, target: self, action: #selector(preparedButtonTapped))
        navigationItem.rightBarButtonItem = preparedButton
    }
    
    @objc func preparedButtonTapped() {
        navigationController?.pushViewController(PreparedKarwiaStaraVC(), animated: true)
    }
    
}
//MARK: - UITableViewDelegate

extension KarwiaStaraVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(orderArray.count)
        return orderArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = productTableView.dequeueReusableCell(withIdentifier: "orderCell") as? OrderCell else {return UITableViewCell()}
    
        
        if !orderArray[indexPath.row].contains("http") {
                cell.configure(image: nil, text: orderArray[indexPath.row])
            }
        else {
            if let image = imageDictionnaris[orderArray[indexPath.row]] {
                print("g")
                cell.configure(image: image, text: nil)
            }}
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if orderArray[indexPath.row].contains("http") {
                return 300
            }
        else {
            return UITableView.automaticDimension
        }

    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let doneAction = UIContextualAction(style: .normal, title: "Przygotowane") { actiion, view, completionHandler in
            
            if let preparedItem = self.productTableView.cellForRow(at: indexPath)?.textLabel?.text {
                self.db.collection("KarwiaStaraPrepared").addDocument(data: [
                    "date": Date().timeIntervalSince1970,
                    "prepared" : preparedItem
                ]) { error in
                    if error == nil {
                        print("Problem z przesłaniem danych do KarwiaStaraPrepared")
                    }
                }
            
            }
        
            
            self.db.collection("KarwiaStaraOrder").document(self.docIDArray[indexPath.row]).delete { error in
                if let e = error {
                    print("the was an issue retreving data from Firebase \(e)")
                }
            }
            
            self.orderArray.remove(at: indexPath.row)
            self.docIDArray.remove(at: indexPath.row)
            self.productTableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        
        }
        let configuration = UISwipeActionsConfiguration(actions: [doneAction])
         return configuration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Usuń") { action, view, completionHandler in
            
            if let itemAboutToBeRemowe = self.productTableView.cellForRow(at: indexPath)?.textLabel?.text {
                self.db.collection("KarwiaStaraOrder").document(self.docIDArray[indexPath.row]).delete { error in
                    if let e = error {
                        print("the was an issue retreving data from Firebase \(e)")
                        
                    }
                }
                self.orderArray.remove(at: indexPath.row)
                self.docIDArray.remove(at: indexPath.row)
            }
            
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
           return configuration    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(actionProvider: { _ in
             
            let dami = UIAction(title: "Dami", image: UIImage(named: "Dami")) { _ in
                if let damiItem = self.productTableView.cellForRow(at: indexPath)?.textLabel?.text {
                    self.db.collection("Dami").addDocument(data: [
                        "date": Date().timeIntervalSince1970,
                        "prepared" : damiItem
                    ]) { error in
                        if error != nil {
                            print("Problem z przesłaniem danych do KarwiaStaraPrepared")
                        }
                    }
                    self.db.collection("KarwiaStaraOrder").document(self.docIDArray[indexPath.row]).delete { error in
                        if let e = error {
                            print("the was an issue retreving data from Firebase \(e)")
                        }
                    }
                }
            }
            let rafix = UIAction(title: "Rafix") { _ in
                if let rafixItem = self.productTableView.cellForRow(at: indexPath)?.textLabel?.text {
                    self.db.collection("Rafix").addDocument(data: [
                        "date": Date().timeIntervalSince1970,
                        "prepared" : rafixItem
                    ]) { error in
                        if error != nil {
                            print("Problem z przesłaniem danych do KarwiaStaraPrepared")
                        }
                    }
                    self.db.collection("KarwiaStaraOrder").document(self.docIDArray[indexPath.row]).delete { error in
                        if let e = error {
                            print("the was an issue retreving data from Firebase \(e)")
                        }
                    }
                }
            }
            let lambra = UIAction(title: "Lambra") { _ in
                if let lambraItem = self.productTableView.cellForRow(at: indexPath)?.textLabel?.text {
                    self.db.collection("Lambra").addDocument(data: [
                        "date": Date().timeIntervalSince1970,
                        "prepared" : lambraItem
                    ]) { error in
                        if error != nil {
                            print("Problem z przesłaniem danych do KarwiaStaraPrepared")
                        }
                    }
                    self.db.collection("KarwiaStaraOrder").document(self.docIDArray[indexPath.row]).delete { error in
                        if let e = error {
                            print("the was an issue retreving data from Firebase \(e)")
                        }
                    }
                }
            }
            let madang = UIAction(title: "Madang") { _ in
                if let madangItem = self.productTableView.cellForRow(at: indexPath)?.textLabel?.text {
                    self.db.collection("Madang").addDocument(data: [
                        "date": Date().timeIntervalSince1970,
                        "prepared" : madangItem
                    ]) { error in
                        if error != nil {
                            print("Problem z przesłaniem danych do KarwiaStaraPrepared")
                        }
                    }
                    self.db.collection("KarwiaStaraOrder").document(self.docIDArray[indexPath.row]).delete { error in
                        if let e = error {
                            print("the was an issue retreving data from Firebase \(e)")
                        }
                    }
                }            }
            let inne = UIAction(title: "Inne") { _ in
                if let otherItem = self.productTableView.cellForRow(at: indexPath)?.textLabel?.text {
                    self.db.collection("Inne").addDocument(data: [
                        "date": Date().timeIntervalSince1970,
                        "prepared" : otherItem
                    ]) { error in
                        if error != nil {
                            print("Problem z przesłaniem danych do KarwiaStaraPrepared")
                        }
                    }
                    self.db.collection("KarwiaStaraOrder").document(self.docIDArray[indexPath.row]).delete { error in
                        if let e = error {
                            print("the was an issue retreving data from Firebase \(e)")
                        }
                    }
                }
            }
            
            return UIMenu(title: "Do kogo przypisać brak", children: [dami, rafix, lambra, madang, inne])
        })
       
        return configuration
    }
    
    
    
}
//MARK: - keyboard
extension KarwiaStaraVC {

    func keyboardSetup () {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notyfication:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    
    @objc private func keyboardWillShow(notyfication: NSNotification) {
        if let indexPath = findActiveTextField() {
            productTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            indexPathforActiveTextField = indexPath
            print("keyboardWillShow : indexPatchForActiveTextField = \(String(describing: indexPathforActiveTextField))")
            print(ipath as Any)
            }
        }
    

    
    @objc func findActiveTextField() -> IndexPath? {
    
        for cell in productTableView.visibleCells {
            if let textField = cell.contentView.subviews.first(where: { $0 is UITextField }) as? UITextField {
                 if textField.isFirstResponder {
                    return productTableView.indexPath(for: cell)
                     
                }
            }
        }
        return nil
    }
    
}
//MARK: - UITextFieldDelegate
extension KarwiaStaraVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        passingDataToCloud()
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Konwertuj punkt (np. 0, 0) pola tekstowego względem tabeli
        let point = textField.convert(CGPoint.zero, to: productTableView)
        // Znajdź indexPath dla komórki, w której znajduje się to pole tekstowe
        if let indexPath = productTableView.indexPathForRow(at: point) {
            indexPathforActiveTextField = indexPath
            print("Aktualny indexPath: \(indexPath)")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
               if let cell = textField.superview?.superview as? UITableViewCell {
                   print("tak")
                   if let indexPath = productTableView.indexPath(for: cell) {
                       print("TextField zakończył edytowanie w komórce na indeksie: \(indexPath.row)")
                       // Możesz teraz wykonać operacje specyficzne dla tej komórki lub indeksu
                   }
               }
        print("494: \(String(describing: ipath))")
        guard indexPathforActiveTextField != nil else {return}
        if reason == .committed {
            if let text = textField.text {
                db.collection("KarwiaStaraOrder").document(docIDArray[indexPathforActiveTextField!.row]).setData([
                "Order": text
            ]) { error in
                if error != nil {
                    print("problem z przesłaniem danych")
                } }
            
                }
            }
    }
}


// 
extension KarwiaStaraVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func openCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .camera
        present(picker, animated: true)
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            let imagaData = image.jpegData(compressionQuality: 0.8)

            let path = "orders/\(UUID().uuidString).jpeg"
            let fileRef = storageRef.child(path)
            fileRef.putData(imagaData!, metadata: nil) { metadata, error in
                if error == nil && metadata != nil {
                    print("przesyłanie danych się powiodło")
                    fileRef.downloadURL { url, error in
                        if let e = error {
                            print("Wystąpił problem z odczytaniem ścieżki URL \(e)")
                        }
                        else {
                            if let pictureURL = url?.absoluteString {
                                print(pictureURL)
                                    self.db.collection("KarwiaStaraOrder").addDocument(data: [
                                    "Order": pictureURL,
                                    "Date": Date().timeIntervalSince1970,
                                    
                                ]) {error in
                                    if error != nil{
                                        print("Problem z przesłaniem danych zdjęcia do firebase")
                                    }
                                }
                            }
                        }
                        
                    }
                }
                else {
                    print("problem z przesłaniem zdjęcia")
                }
            }
        }
            dismiss(animated: true, completion: nil)
            productTableView.reloadData()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
    }

