//
//  RequestDetailViewController.swift
//  FixThis
//
//  Created by John Choi on 8/24/20.
//  Copyright © 2020 John Choi. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class RequestDetailViewController: UIViewController {

    @IBOutlet weak var originalTextView: UITextView!
    @IBOutlet weak var revisedTextView: UITextView!
    @IBOutlet weak var isCompleteSwitch: UISwitch!
    
    var request: Request!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        IQKeyboardManager.shared.enable = true
        originalTextView.text = request.original
        revisedTextView.text = request.revised
        isCompleteSwitch.setOn(request.isComplete, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = false
    }
    
    @IBAction func copyButtonPressed(_ sender: UIButton) {
        revisedTextView.text = originalTextView.text
    }
    
    @IBAction func switchPressed(_ sender: UISwitch) {
        // TODO: update isComplete on Firebase
    }
}
