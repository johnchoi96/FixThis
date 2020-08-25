//
//  RequestDetailViewController.swift
//  FixThis
//
//  Created by John Choi on 8/24/20.
//  Copyright © 2020 John Choi. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase

class RequestDetailViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var originalTextView: UITextView!
    @IBOutlet weak var revisedTextView: UITextView!
    @IBOutlet weak var isCompleteSwitch: UISwitch!
    @IBOutlet weak var copyButton: UIButton!
    
    var request: Request!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        IQKeyboardManager.shared.enable = true
        originalTextView.delegate = self
        revisedTextView.delegate = self
        originalTextView.text = request.original
        revisedTextView.text = request.revised
        
        originalTextView.layer.cornerRadius = 15
        revisedTextView.layer.cornerRadius = 15
        isCompleteSwitch.setOn(request.isComplete, animated: false)
        
        originalTextView.backgroundColor = .darkGray
        originalTextView.textColor = .white
        revisedTextView.textColor = .white
        if isCompleteSwitch.isOn {
            revisedTextView.isEditable = false
            revisedTextView.backgroundColor = .darkGray
        } else {
            revisedTextView.isEditable = true
            revisedTextView.backgroundColor = .opaqueSeparator
        }
        copyButton.isHidden = isCompleteSwitch.isOn
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = false
    }
    
    @IBAction func copyButtonPressed(_ sender: UIButton) {
        revisedTextView.text = originalTextView.text
        updateData()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateData()
    }
    
    @IBAction func completeSwitchPressed(_ sender: UISwitch) {
        updateData()
        if isCompleteSwitch.isOn {
            revisedTextView.isEditable = false
            revisedTextView.backgroundColor = .darkGray
        } else {
            revisedTextView.isEditable = true
            revisedTextView.backgroundColor = .opaqueSeparator
        }
        copyButton.isHidden = sender.isOn
    }
    
    private func updateData() {
        // update data on Firebase
        db.collection("requests").document(request.documentId).setData([
            "original": originalTextView.text ?? "",
            "revised": revisedTextView.text ?? "",
            "isComplete": isCompleteSwitch.isOn,
            "timestamp": Date().timeIntervalSince1970
        ]) { error in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: "Error while updating data\n\(error)", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        request.isComplete = isCompleteSwitch.isOn
    }
}
