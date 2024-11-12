//
//  FirebaseCloudLogic.swift
//  Libro
//
//  Created by Patryk Danielewicz on 03/10/2024.
//

import Foundation
import Firebase
import FirebaseStorage
import CoreData

class FirebaseCloudLogic {
    
    private let db                     = Firestore.firestore()
    private let storageRef             = Storage.storage().reference()
    private let metadata               = StorageMetadata()
    
    private let contex                         = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static var orderAray: [Order]             = []
    static var docID: [String]         = []
    static var docIDInCloud: [String]  = []
    
    func retrivingDataFromCloud(storeIndentifier: StoreIndentifier, orderStatus: OrderStatus, completion: @escaping (String, Bool) -> Void) {
        let collectionName = (storeIndentifier.rawValue).capitalized + (orderStatus.rawValue).capitalized
        guard let placeholderImage = (UIImage(systemName: "photo"))?.jpegData(compressionQuality: 0.8) else {return}
        
        if orderStatus == .ordered {
            
            db.collection(collectionName).order(by: CloudDictionaryKeys.date).addSnapshotListener { [weak self] querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return}
            
                snapshot.documentChanges.forEach { diff in

                    let data = diff.document.data()
                    let documentID = diff.document.documentID
                   
                    
                
                    let rawDate = data[CloudDictionaryKeys.date]
                    let date = Date(timeIntervalSince1970: rawDate as! TimeInterval)

                    if diff.type == .added {
                        if FirebaseCloudLogic.docIDInCloud.contains(documentID) { return }
                        if FirebaseCloudLogic.docID.contains(documentID) {
                            FirebaseCloudLogic.docIDInCloud.append(documentID)
                            return}
                        
                        FirebaseCloudLogic.docIDInCloud.append(documentID)
                        
                        if let order = data[CloudDictionaryKeys.order] as? String {
                            
                            if order.contains("http") {
                                self?.addOrder(date: date, order: "zdjęcie", image: placeholderImage, docID: documentID)
                                completion(documentID, true)
    
                                Task {
                                    guard let image = try? await self?.getImage(imagePath: order) else { print ("Error fetching image"); return}
                                    if let index = FirebaseCloudLogic.orderAray.firstIndex(where: { order in
                                        order.docID == documentID
                                    }) {
                                        FirebaseCloudLogic.orderAray[index].image = image }
                                    DispatchQueue.main.async { completion(documentID, true) }
                                }
                            }
                            else {
                                self?.addOrder(date: date, order: order, image: nil, docID: documentID)
                                completion(documentID, true)
                            }
                        }
                    }
                    if (diff.type == .modified) {
                        if let order = data[CloudDictionaryKeys.order] as? String {
                            if let index = FirebaseCloudLogic.orderAray.firstIndex(where: { order in
                                order.docID == documentID
                            }) {
                                FirebaseCloudLogic.orderAray[index].text = order
                            }
                            completion(documentID, true)
                            }
                        }
                    if (diff.type == .removed) {
//                        FirebaseCloudLogic.dataCache.removeObject(forKey: diff.document.documentID as NSString)
//                       FirebaseCloudLogic.docID.removeAll(where: { $0 == diff.document.documentID })
//                        FirebaseCloudLogic.docIDInCloud.removeAll(where: {$0 == diff.document.documentID})
//                        completion(documentID, false)
                    }
                }
            }
        }
    }

    func getImage(imagePath: String) async throws -> Data? {
        if let url = URL(string: imagePath) {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
            
        }
        return nil
    }
    
    func sendTextToCloud(text: String, storeIndentifier: StoreIndentifier, orderStatus: OrderStatus, DocIDBeingModified: String?) async throws {
        let collectionName = (storeIndentifier.rawValue).capitalized + (orderStatus.rawValue).capitalized
        
        if let modifiedDocID = DocIDBeingModified {
            if FirebaseCloudLogic.docIDInCloud.contains(modifiedDocID) {
                try await db.collection(collectionName).document(modifiedDocID).updateData([CloudDictionaryKeys.order : text])
            }
            else {
                try await db.collection(collectionName).document(modifiedDocID).setData(
                                                                         [CloudDictionaryKeys.order : text,
                                                                         CloudDictionaryKeys.date  : Date().timeIntervalSince1970])
            }
        }
        else {
                try await db.collection(collectionName).addDocument(data:
                                                                        [CloudDictionaryKeys.order : text,
                                                                         CloudDictionaryKeys.date  : Date().timeIntervalSince1970])
            }
    }
    
    func sendImageToCloud(_ image: UIImage, storeIndentifier: StoreIndentifier, orderStatus: OrderStatus) async throws {
        let vcName = (storeIndentifier.rawValue).capitalized + (orderStatus.rawValue).capitalized
        let path = vcName + "/" + UUID().uuidString + ".jpg"
        
        if let imageData = image.jpegData(compressionQuality: 0.7) {
            let ref = storageRef.child(path)
            try await ref.putDataAsync(imageData)
            let url = try await ref.downloadURL()
            try await sendTextToCloud(text: url.absoluteString, storeIndentifier: storeIndentifier, orderStatus: orderStatus, DocIDBeingModified: nil)
        }
    }
    
    func removeTextFromCloud(storeIndentifier: StoreIndentifier, orderStatus: OrderStatus, DocIDBeingModified: String) async throws {
        let collectionName = (storeIndentifier.rawValue).capitalized + (orderStatus.rawValue).capitalized
        try await db.collection(collectionName).document(DocIDBeingModified).delete()
    }
    
    func saveContext() {
        do {
            try contex.save()
        }
        catch {
            print("Error saving context: \(error)")
        }
    }
    
    func addOrder(date: Date, order: String, image: Data?, docID: String) {
        let newOrder = Order(context: contex)
        newOrder.date = date
        if let image = image {
            newOrder.image = image
            newOrder.text = "zdjęcie"
            newOrder.docID = docID
        }
        newOrder.text = order
        newOrder.docID = docID
         
    }
    
    func loadOrders() {
        let request: NSFetchRequest<Order> = Order.fetchRequest()
        do {
            FirebaseCloudLogic.orderAray = try  contex.fetch(request)
        }
        catch {
            print("Error fetching orders: \(error)")
        }
    }

}

