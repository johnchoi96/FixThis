//
//  FixThisManager.swift
//  FixThis
//
//  Created by John Choi on 8/23/20.
//  Copyright © 2020 John Choi. All rights reserved.
//

import Foundation
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
        db.collection("requests").order(by: "timestamp").addSnapshotListener { (querySnapshot, error) in
            if self.requests.count > 0 {
                self.requests.removeAll()
            }
            if let error = error {
                print("There was an issue with connecting to the database, \(error)")
            } else {
                if let snapshotDocs = querySnapshot?.documents {
                    for doc in snapshotDocs {
                        let data = doc.data()
                        let request = Request(original: data["original"] as! String, revised: data["revised"] as! String, isComplete: data["isComplete"] as! Bool, documentId: doc.documentID)
                        self.requests.append(request)
                    }
                    DispatchQueue.main.async {
                        self.delegate?.dataUpdated()
                    }
                }
            }
        }
    }
}
