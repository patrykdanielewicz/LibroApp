//
//  FirebaseCloudLogic.swift
//  Libro
//
//  Created by Patryk Danielewicz on 03/10/2024.
//

import Foundation
import Firebase
import FirebaseStorage

//MARK: - FDSDelegate

protocol FirebaseDataStorageDelegate: AnyObject {
    func dataStorageDidUpdate()
}

//MARK: - FDSActor

actor FirebaseDataStorage {
    
    static let shared              = FirebaseDataStorage()
    
    weak var delegate: FirebaseDataStorageDelegate?
    
    var dataStorage: [String: Any] = [:]
    var docID: [String]            = []
    var docIDInCloud: [String]     = []

    func setDelegate(_ delegate: FirebaseDataStorageDelegate) {
        self.delegate = delegate
    }
    
    func containsDocumetIDInCloud(documentID: String) -> Bool {
        return docIDInCloud.contains(documentID)
    }
    
    func containsDocumentID(documentID: String) -> Bool {
        return docID.contains(documentID)
    }
    
    func addDocumentIDToCloud(documentID: String) {
        docIDInCloud.append(documentID)
        
    }
    
    func addDocumentIDToLocal(documentID: String) {
        docID.append(documentID)
    }
    
    func addDataToStorage(documentID: String, data: Any) {
        dataStorage[documentID] = data
        delegate?.dataStorageDidUpdate()
    }
    
    func removeDataFromDataStorage(documentID: String) {
        dataStorage.removeValue(forKey: documentID)
        delegate?.dataStorageDidUpdate()
    }
    
    func removeDocumentIDFromCloud(documentID: String) {
        docIDInCloud.removeAll(where: { $0 == documentID })
        delegate?.dataStorageDidUpdate()
    }
    
    func removeDocumentIDFromLocal(documentID: String) {
        docID.removeAll(where: { $0 == documentID })
    }
    
    func insertDocID(documetID: String, at: Int) {
        docID.insert(documetID, at: at)
//        delegate?.dataStorageDidUpdate()
    }
    
    func getCachedData(for key: String) -> Any? {
        return dataStorage[key]
    }
    
    func getData() -> [String: Any] {
        return dataStorage
    }
    func getDocID() -> [String] {
        return docID
    }
    
}

//MARK: - FCL

class FirebaseCloudLogic {
    
    private let db                           = Firestore.firestore()
    private let storageRef                   = Storage.storage().reference()
    private let metadata                     = StorageMetadata()
    
    private let FDS                          = FirebaseDataStorage.shared
    
    func retrivingDataFromCloud(dataSourceName collectionName: String) {
    
        guard let placeholderImage = UIImage(systemName: "photo") else {return}
        
            db.collection(collectionName).order(by: CloudDictionaryKeys.date).addSnapshotListener { [weak self] querySnapshot, error in

                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return}
            
                snapshot.documentChanges.forEach { diff in
                  

                    
                    let data = diff.document.data()
                    let documentID = diff.document.documentID
                    
                    Task {
                        if diff.type == .added {
                            let alreadyInCloud = await self?.FDS.containsDocumetIDInCloud(documentID:  documentID)
                            let alreadyInTableView = await self?.FDS.containsDocumentID(documentID: documentID)
                            
                            if alreadyInCloud == true {
                                return }
                            if alreadyInTableView == true {
                                await self?.FDS.addDocumentIDToCloud(documentID: documentID)
                                return}
                            
                            
                            await self?.FDS.addDocumentIDToCloud(documentID: documentID)
                            
                            if let order = data[CloudDictionaryKeys.order] as? String {
                                
                                if order.contains("http") {
                                    await self?.FDS.addDataToStorage(documentID: documentID, data: placeholderImage)
                                    await self?.FDS.addDocumentIDToCloud(documentID: documentID)
                                    await self?.FDS.addDocumentIDToLocal(documentID: documentID)
                                    
                                    Task {
                                        guard let image = try? await self?.getImage(imagePath: order) else { print ("Error fetching image"); return}
                                        await self?.FDS.addDataToStorage(documentID: documentID, data: image)
                                    }
                                }
                                else {
                                    
                                    await self?.FDS.addDataToStorage(documentID: documentID, data: order)
                                    await self?.FDS.addDocumentIDToCloud(documentID: documentID)
                                    await self?.FDS.addDocumentIDToLocal(documentID: documentID)
                                    
                                }
                            }
                        }
                        if (diff.type == .modified) {
                            if let order = data[CloudDictionaryKeys.order] as? String {
                                await self?.FDS.addDataToStorage(documentID: documentID, data: order)
                            }
                        }
                        if (diff.type == .removed) {
                            await self?.FDS.removeDataFromDataStorage(documentID: documentID)
                            await self?.FDS.removeDocumentIDFromCloud(documentID: documentID)
                            await self?.FDS.removeDocumentIDFromLocal(documentID: documentID)
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
            if await FDS.containsDocumetIDInCloud(documentID: modifiedDocID) {
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

