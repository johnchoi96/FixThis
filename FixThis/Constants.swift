//
//  Constants.swift
//  FixThis
//
//  Created by John Choi on 8/23/20.
//  Copyright © 2020 John Choi. All rights reserved.
//

import Foundation
import LocalAuthentication

struct K {
    struct Cells {
        static let requestCellIdent = "requestCell"
        static let requestCellNibName = "RequestTableViewCell"
    }
    
    struct Segues {
        static let mainToSubmitRequest = "mainToSubmitRequest"
        static let mainToRequestDetail = "mainToRequestDetail"
        static let loginToMain = "loginToMain"
        static let signupToMain = "signupToMain"
        static let welcomeToSignup = "welcomeToSignup"
        static let welcomeToLogin = "welcomeToLogin"
    }
    
    /**
     Returns the available biometric authentication method available for this device.
     Returns none if this device does not have a biometric authentication method. e.g. iPod Touch
     */
    static var BIOMETRIC_METHOD: String {
        if LAContext().biometryType == .faceID {
            return "Face ID"
        } else if LAContext().biometryType == .touchID {
            return "Touch ID"
        } else {
            return "Face ID/Touch ID"
        }
    }
}
