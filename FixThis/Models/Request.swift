//
//  Request.swift
//  FixThis
//
//  Created by John Choi on 8/23/20.
//  Copyright © 2020 John Choi. All rights reserved.
//

import Foundation

struct Request {
    
    var original: String
    var revised: String
    var isComplete: Bool
    let documentId: String
    let submitterEmail: String?
}
