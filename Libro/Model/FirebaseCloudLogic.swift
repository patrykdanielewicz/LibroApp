//
//  FirebaseCloudLogic.swift
//  Libro
//
//  Created by Patryk Danielewicz on 03/10/2024.
//

import Foundation
import Firebase
import FirebaseStorage

class FirebaseCloudLogic {
    
    private let db                     = Firestore.firestore()
    private let storageRef             = Storage.storage().reference()
    private let metadata               = StorageMetadata()
    
    static let dataCache               = NSCache<NSString, AnyObject>()
    static var docID: [String]         = []
    static var docIDInCloud: [String]  = []
    
    func retrivingDataFromCloud(storeIndentifier: StoreIndentifier, orderStatus: OrderStatus, completion: @escaping (String, Bool) -> Void) {
        let collectionName = (storeIndentifier.rawValue).capitalized + (orderStatus.rawValue).capitalized
        guard let placeholderImage = UIImage(systemName: "photo") else {return}
        
        if orderStatus == .ordered {
            
            db.collection(collectionName).order(by: CloudDictionaryKeys.date).addSnapshotListener { [weak self] querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return}
            
                snapshot.documentChanges.forEach { diff in
                    
                    let data = diff.document.data()
                    let documentID = diff.document.documentID
                    
                    if diff.type == .added {
                        
                        if FirebaseCloudLogic.docIDInCloud.contains(documentID) { return }
                        if FirebaseCloudLogic.docID.contains(documentID) {
                            FirebaseCloudLogic.docIDInCloud.append(documentID)
                            return}
//                        
//                        FirebaseCloudLogic.docID.append(documentID)
                        FirebaseCloudLogic.docIDInCloud.append(documentID)
                        
                        if let order = data[CloudDictionaryKeys.order] as? String {
                            
                            if order.contains("http") {
                                FirebaseCloudLogic.dataCache.setObject(placeholderImage, forKey: documentID as NSString)
                                completion(documentID, true)
    
                                Task {
                                    guard let image = try? await self?.getImage(imagePath: order) else { print ("Error fetching image"); return}
                                    FirebaseCloudLogic.dataCache.setObject(image as UIImage, forKey: documentID as NSString)
                                    DispatchQueue.main.async { completion(documentID, true) }
                                }
                            }
                            else {
                                    FirebaseCloudLogic.dataCache.setObject(order as NSString, forKey: documentID as NSString)
                                completion(documentID, true)
                            }
                        }
                    }
                    if (diff.type == .modified) {
                        if let order = data[CloudDictionaryKeys.order] as? String {
                            FirebaseCloudLogic.dataCache.setObject(order as NSString, forKey: documentID as NSString)
                            completion(documentID, true)
                            }
                        }
                    if (diff.type == .removed) {
                        FirebaseCloudLogic.dataCache.removeObject(forKey: diff.document.documentID as NSString)
//                        FirebaseCloudLogic.docID.removeAll(where: { $0 == diff.document.documentID })
                        FirebaseCloudLogic.docIDInCloud.removeAll(where: {$0 == diff.document.documentID})
                        completion(documentID, false)
                    }
                }
            }
        }
    }

    func getImage(imagePath: String) async throws -> UIImage? {
        if let url = URL(string: imagePath) {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                    return image
            }
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

}

