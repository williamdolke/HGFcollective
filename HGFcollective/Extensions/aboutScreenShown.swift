//
//  aboutScreenShown.swift
//  HGFcollective
//
//  Created by William Dolke on 15/01/2023.
//

import Foundation

extension UserDefaults {
    var aboutScreenShown: Bool {
        get {
            return (UserDefaults.standard.bool(forKey: "aboutScreenShown"))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "aboutScreenShown")
        }
    }
}
