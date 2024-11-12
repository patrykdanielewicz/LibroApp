//
//  DefaultViewController.swift
//  Libro
//
//  Created by Patryk Danielewicz on 03/10/2024.
//

import UIKit


class DefaultViewController: UIViewController {
  
    private var constantValuesAndNames                  = ConstantValuesAndNames()
    private var firebaseCloudLogic                      = FirebaseCloudLogic()
    
    private let orderTableView                          = UITableView()
    private let sendButton                              = UIButton()
    private let cameraButton                            = CameraButton()
    
    private lazy var addNewOrderButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
    private lazy var doneButton: UIBarButtonItem        = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))

    private let orderImputSV                            = UIStackView()
    private let mainSV                                  = UIStackView()
    
    private let storeIndentifier: StoreIndentifier
    private let orderStatus: OrderStatus
    
    private var isKeyboardVisible: Bool = false
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init (storeIndentifier: StoreIndentifier, orderStatus: OrderStatus) {
        self.storeIndentifier = storeIndentifier
        self.orderStatus      = orderStatus
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnScreen))
        
        
        
        
        view.addGestureRecognizer(tabGesture)
        view.backgroundColor                             = UIColor.systemBackground
        view.keyboardLayoutGuide.followsUndockedKeyboard = true
        
        navigationController?.isNavigationBarHidden      = false
        title                                            = constantValuesAndNames.getStoreName(formStoreIndentifier: storeIndentifier)
        navigationController?.navigationBar.tintColor    = ConstantValuesAndNames.secondColor
        
        navigationItem.rightBarButtonItem                = addNewOrderButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(ifKeyboardOnScreen), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ifKeyboardOnScreen), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        configMainSV()
        
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        
        firebaseCloudLogic.retrivingDataFromCloud(storeIndentifier: storeIndentifier, orderStatus: orderStatus) { documentID, isOrderAdded in
            DispatchQueue.main.async { [weak self] in
                if FirebaseCloudLogic.orderAray == [] {
                    self?.firebaseCloudLogic.loadOrders()
                    self?.orderTableView.reloadData()
                }
                
                if isOrderAdded {
                    self?.firebaseCloudLogic.loadOrders()
                    if FirebaseCloudLogic.docID.contains(documentID) {
                        if let index = FirebaseCloudLogic.orderAray.firstIndex(where: { order in
                            order.docID == documentID
                        }) {
                            let indexPath = IndexPath(row: index, section: 0)
                            self?.orderTableView.reloadRows(at: [indexPath], with: .automatic)
                            
                        }
                        else {
                            FirebaseCloudLogic.docID.append(documentID)
                            if let index = FirebaseCloudLogic.orderAray.firstIndex(where: { order in
                                order.docID == documentID
                            }) {
                                let indexPath = IndexPath(row: index, section: 0)
                                self?.firebaseCloudLogic.loadOrders()
                                self?.orderTableView.insertRows(at: [indexPath], with: .automatic)
                            }
                        }
                    } }
                    else {
                        //                        self?.orderTableView.deleteRows(at: [indexPath], with: .automatic)
                    }
               
                
            }
            
        }
    }
    func configOrderInputSV() {
        orderImputSV.translatesAutoresizingMaskIntoConstraints = false
        orderImputSV.axis                                      = .horizontal
        orderImputSV.distribution                              = .fill
        orderImputSV.spacing                                   = 10
        orderImputSV.isLayoutMarginsRelativeArrangement        = true
        orderImputSV.layoutMargins = UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 10)
        
        let space = UIView()
        space.translatesAutoresizingMaskIntoConstraints        = false
        
        orderImputSV.addArrangedSubview(cameraButton)
        orderImputSV.addArrangedSubview(space)
    
        
        NSLayoutConstraint.activate([
            cameraButton.leadingAnchor.constraint(equalTo: orderImputSV.leadingAnchor, constant: 10),
            cameraButton.heightAnchor.constraint(equalToConstant: 44),
            cameraButton.widthAnchor.constraint(equalToConstant: 44)])
    }
    
    func configMainSV() {
        view.addSubview(mainSV)
        
        configOrderInputSV()
        
        mainSV.translatesAutoresizingMaskIntoConstraints         = false
        mainSV.axis                                              = .vertical
        mainSV.distribution                                      = .fill
        mainSV.spacing                                           = 5
        
        orderTableView.translatesAutoresizingMaskIntoConstraints = false
        orderTableView.dataSource                                = self
        orderTableView.delegate                                  = self
        orderTableView.rowHeight                                 = UITableView.automaticDimension
        orderTableView.estimatedRowHeight                        = 30
        orderTableView.register(OrderCell.self, forCellReuseIdentifier: ConstantValuesAndNames.cellIdentifier)
        
        mainSV.addArrangedSubview(orderTableView)
        mainSV.addArrangedSubview(orderImputSV)
        
        NSLayoutConstraint.activate([
            mainSV.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            mainSV.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mainSV.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mainSV.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -5),
            
            orderImputSV.bottomAnchor.constraint(equalTo: mainSV.bottomAnchor),
        ])
        
    }
    
    @objc func cameraButtonTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
        
        //    func connectionIssueAlert() {
        //
        //        let ac = UIAlertController(title: "Błąd", message: "Wystąpił problem podczas pobierania danych z serwera. Sprawdz połączenie interentowe i spoóbuj ponownie", preferredStyle: .alert)
        //        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //        ac.addAction(UIAlertAction(title: "Spórubuj ponownie", style: .default, handler: { action in
        //            self.firebaseCloudLogic.retrivingDataFromCloud(storeIndentifier: self.storeIndentifier, orderStatus: self.orderStatus) { done in
        //                if done {
        //                    self.orderTableView.reloadData()
        //                }
        //                else {
        //                    self.connectionIssueAlert()
        //                }
        //            }
        //        }))
        //        present(ac, animated: true)
        //    }
    
    @objc func ifKeyboardOnScreen(notification: Notification) {
        if notification.name == UIResponder.keyboardWillShowNotification {
            orderImputSV.isHidden = true
            isKeyboardVisible = true
            navigationItem.rightBarButtonItem = doneButton}
        else if notification.name == UIResponder.keyboardWillHideNotification {
            orderImputSV.isHidden = false
            isKeyboardVisible = false
            navigationItem.rightBarButtonItem = addNewOrderButton
        }
    }
    
    @objc func tapOnScreen() {
        if isKeyboardVisible == true {
            orderTableView.visibleCells.forEach { cell in
                if let OrderCell = cell as? OrderCell {
                    if OrderCell.customText.isFirstResponder {
                        OrderCell.customText.resignFirstResponder()
                    }
                }
            }
        }
        else {
            addNewCell(.new)
        }
    }
    
    @objc func addButtonPressed() {
        addNewCell(.new)
    }
    
    @objc func doneButtonPressed() {
        view.endEditing(true)
    }
   
}
    //MARK: - TableView
    
extension DefaultViewController: UITableViewDataSource, UITableViewDelegate, OrderCellDelegate {
    
    func modifiedTextInCell(cell: OrderCell, text: String?) {
        if let rowFromIndexPath = orderTableView.indexPath(for: cell)?.row {
            let docIDBeingModified = FirebaseCloudLogic.docID[rowFromIndexPath]
            if let text = text {
//                FirebaseCloudLogic.dataCache.setObject(text as NSString, forKey: docIDBeingModified as NSString)
                    Task {
                        do {
                            try await firebaseCloudLogic.sendTextToCloud(text: text, storeIndentifier: storeIndentifier, orderStatus: orderStatus, DocIDBeingModified: docIDBeingModified)
                        }
                        catch {
                            print(error)
                    }
                }
                addNewCell(.cell(cell))
            }
        }
    }
    
    func addNewCell(_ input: AddNewCellArguments) {
        var newIndexPathRow: Int?
        let creadtedDocID = UUID().uuidString
        
        switch input {
        case .row(let row):
            newIndexPathRow = row + 1
        case .cell(let cell):
            if let indexPath = orderTableView.indexPath(for: cell) {
                newIndexPathRow = indexPath.row + 1 }
        case .new:
            newIndexPathRow = FirebaseCloudLogic.docID.count
        }
        
        guard let newIndexPathRow  else { return }
        let indexPath = IndexPath(row: newIndexPathRow, section: 0)
    
        if newIndexPathRow == FirebaseCloudLogic.docID.count {
            FirebaseCloudLogic.docID.append(creadtedDocID)
            }
        else {
            FirebaseCloudLogic.docID.insert(creadtedDocID, at: newIndexPathRow)
            }
        
//        FirebaseCloudLogic.dataCache.setObject(text as NSString, forKey: creadtedDocID as NSString)

        orderTableView.performBatchUpdates {
            orderTableView.insertRows(at: [indexPath], with: .automatic)} completion: { [weak self] _ in
            self?.orderTableView.scrollToRow(at: indexPath, at: .middle, animated: false)
            if let newCell = self?.orderTableView.cellForRow(at: indexPath) as? OrderCell {
                newCell.customText.becomeFirstResponder()
            }
        }
    }
    
    func removeCell(cell: OrderCell) {

        if let indexPath = orderTableView.indexPath(for: cell) {
            let docIDname = FirebaseCloudLogic.docID[indexPath.row]
            if FirebaseCloudLogic.docIDInCloud.contains(docIDname) {
                Task {
                    do {
                        try await firebaseCloudLogic.removeTextFromCloud(storeIndentifier: storeIndentifier, orderStatus: orderStatus, DocIDBeingModified: docIDname)
                        addNewCell(.cell(cell))
                    }
                    catch {
                        print("Error removing text from cloud: \(error)")
                    }
                }
            }
            else {
                FirebaseCloudLogic.docID.remove(at: indexPath.row)
//                FirebaseCloudLogic.dataCache.removeObject(forKey: docIDname as NSString)
                orderTableView.beginUpdates()
                orderTableView.deleteRows(at: [indexPath], with: .automatic)
                orderTableView.endUpdates()
                
            }
        }
    }
    
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return FirebaseCloudLogic.orderAray.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ConstantValuesAndNames.cellIdentifier) as? OrderCell else { return UITableViewCell() }
            cell.delegate = self
            cell.tag = indexPath.row
    
            if let cachedImage = FirebaseCloudLogic.orderAray[indexPath.row].image {
                let image = UIImage(data: cachedImage)
                cell.configure(image: image, text: nil)
                }
                else {
                    if let text = FirebaseCloudLogic.orderAray[indexPath.row].text {
                        cell.configure(image: nil, text: text)
                    }
                }
            
            return cell
        }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cachedImage = FirebaseCloudLogic.orderAray[indexPath.row].image {
            return 300
        }
        else  {
            let automatic = UITableView.automaticDimension
            return automatic
        }
        }
        
        
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteCell = UIContextualAction(style: .destructive, title: "Usuń") { (action, sourceView, completionHandler) in
            Task {
                try? await self.firebaseCloudLogic.removeTextFromCloud(storeIndentifier: self.storeIndentifier, orderStatus: self.orderStatus, DocIDBeingModified: FirebaseCloudLogic.docID[indexPath.row])
            }
            FirebaseCloudLogic.docID.remove(at: indexPath.row)
//            FirebaseCloudLogic.dataCache.removeObject(forKey: FirebaseCloudLogic.docID[indexPath.row] as NSString)
            FirebaseCloudLogic.docIDInCloud.remove(at: indexPath.row)
            
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteCell])
           return configuration
    }
    }
    
//MARK: - ImagePickerControler

extension DefaultViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            Task {
                do {
                    try await firebaseCloudLogic.sendImageToCloud(image, storeIndentifier: storeIndentifier, orderStatus: orderStatus)
                }
                catch {
                    
                    print(DataError.uploadImageError("Nie mogliśmy wysłać zdjęcia - sprawdź połączenie z internetem"))
                }
            }
            dismiss(animated: true)
        }
    }
}

