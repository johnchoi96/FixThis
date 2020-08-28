//
//  AboutViewController.swift
//  FixThis
//
//  Created by John Choi on 8/24/20.
//  Copyright © 2020 John Choi. All rights reserved.
//

import UIKit
import SafariServices

class AboutViewController: UIViewController {

    @IBOutlet weak var devWebsiteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        devWebsiteButton.layer.cornerRadius = 15
    }
    
    @IBAction func devWebsitePressed(_ sender: UIButton) {
        let url = URL(string: "https://johnchoi96.github.io/FixThis/")
        let vc = SFSafariViewController(url: url!)
        self.present(vc, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
