//
//  SubmitRequestViewController.swift
//  FixThis
//
//  Created by John Choi on 8/23/20.
//  Copyright © 2020 John Choi. All rights reserved.
//

import UIKit
import Firebase

class SubmitRequestViewController: UIViewController {

    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var textviewPlaceholder: UILabel!
    
    var manager: FixThisManager!
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.isModalInPresentation = true
        textview.delegate = self
        textview.becomeFirstResponder()
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        if let originalText = textview.text {
            db.collection("requests").addDocument(data: [
                "original": originalText,
                "revised": "",
                "isComplete": false,
                "timestamp": Date().timeIntervalSince1970,
                "submitter": (Auth.auth().currentUser?.email!)! as String
            ]) { (error) in
                if error != nil {
                    print("Error occurred while saving the data to Firestore. \(error!)")
                } else {
                    let alert = UIAlertController(title: "Save Successful", message: "Request Submitted!", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default) { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }
                    self.manager.loadData()
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SubmitRequestViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            textviewPlaceholder.isHidden = false
        } else {
            textviewPlaceholder.isHidden = true
        }
    }
}
