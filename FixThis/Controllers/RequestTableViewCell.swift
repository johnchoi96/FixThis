//
//  RequestTableViewCell.swift
//  FixThis
//
//  Created by John Choi on 8/23/20.
//  Copyright © 2020 John Choi. All rights reserved.
//

import UIKit

class RequestTableViewCell: UITableViewCell {

    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var completeIndicator: UIView!
    @IBOutlet weak var incompleteIndicator: UIView!
    @IBOutlet weak var submitterEmail: UILabel!
    
    var isComplete: Bool {
        get {
            return incompleteIndicator.isHidden
        }
        set(newValue) {
            incompleteIndicator.isHidden = newValue
            completeIndicator.isHidden = !newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        completeIndicator.layer.cornerRadius = 10
        incompleteIndicator.layer.cornerRadius = 10
        completeIndicator.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
