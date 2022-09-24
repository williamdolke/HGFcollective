//
//  HGFcollectiveApp.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI
import Firebase
import FirebaseAuth

@main
struct HGFcollectiveApp: App {
    init() {
        FirebaseApp.configure()
        
        if UserDefaults.standard.string(forKey: "uid") == nil {
            Auth.auth().signInAnonymously { authResult, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Sucessfully signed in anonymously")
                }
                guard let user = authResult?.user else { return }
                UserDefaults.standard.set(user.uid, forKey: "uid")
                print("UID: \(user.uid)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            LaunchScreen()
                .environmentObject(ArtistManager())
        }
    }
}
