//
//  FixThisManager.swift
//  FixThis
//
//  Created by John Choi on 8/23/20.
//  Copyright © 2020 John Choi. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class FixThisManager {
    
    var requests: [Request]
    var db = Firestore.firestore()
    var delegate: FirebaseDataUpdateDelegate?
    
    init() {
        requests = [Request]()
        loadData()
    }
    
    func loadData() {
        db.collection("requests").order(by: "timestamp", descending: true).addSnapshotListener { (querySnapshot, error) in
            if self.requests.count > 0 {
                self.requests.removeAll()
            }
            if let error = error {
                print("There was an issue with connecting to the database, \(error)")
            } else {
                if let snapshotDocs = querySnapshot?.documents {
                    for doc in snapshotDocs {
                        let data = doc.data()
                        let request = Request(original: data["original"] as! String, revised: data["revised"] as! String, isComplete: data["isComplete"] as! Bool, documentId: doc.documentID, submitterEmail: data["submitter"] as! String?)
                        self.requests.append(request)
                    }
                    DispatchQueue.main.async {
                        self.delegate?.dataUpdated()
                    }
                }
            }
        }
    }
    
    func deleteRequest(id: String, index: Int) throws {
        var errorHappened = false
        db.collection("requests").document(id).delete { (error) in
            if error != nil {
                errorHappened = true
            }
        }
        if errorHappened {
            throw FirebaseError.deleteError("Error happened while deleting request")
        }
        requests.remove(at: index)
    }
}
