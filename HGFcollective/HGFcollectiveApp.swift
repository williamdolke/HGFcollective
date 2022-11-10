//
//  HGFcollectiveApp.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI
import Logging
import Firebase
import FirebaseAuth

let logger = Logger(label: "")

@main
struct HGFcollectiveApp: App {
    init() {
        // Use Firebase library to configure APIs
        FirebaseApp.configure()

        if UserDefaults.standard.string(forKey: "uid") == nil {
            Auth.auth().signInAnonymously { authResult, error in
                if let err = error {
                    logger.error("Error signing into database: \(err.localizedDescription)")
                } else {
                    logger.info("Sucessfully signed in to database anonymously.")
                }
                guard let user = authResult?.user else { return }

                UserDefaults.standard.set(user.uid, forKey: "uid")
                logger.info("Anonymous login UID: \(user.uid)")
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
