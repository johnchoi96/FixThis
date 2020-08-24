//
//  Exception.swift
//  FixThis
//
//  Created by John Choi on 8/24/20.
//  Copyright © 2020 John Choi. All rights reserved.
//

import Foundation

enum FirebaseError: Error {
    case addError(String)
    case updateError(String)
    case deleteError(String)
}
