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
import FirebaseCrashlytics

// Configure a logger that can be used globally
let logger = Logger(label: "")

@main
struct HGFcollectiveApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    var body: some Scene {
        WindowGroup {
            LaunchScreen()
            // Start fetching the artists from the database when the launch screen
            // is created. Hopefully by the time the launch screen is dismissed
            // this will have completed.
                .environmentObject(ArtistManager())
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     // swiftlint:disable line_length
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
                     // swiftlint:enable line_length
        // Use Firebase library to configure APIs
        FirebaseApp.configure()

        signInAnonymously()
        return true
    }
}

func signInAnonymously() {
    if UserDefaults.standard.string(forKey: "uid") == nil {
        // Sign the user in to Firestore anonymously
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                logger.error("Error signing into database: \(error.localizedDescription)")
            } else {
                logger.info("Sucessfully signed in to database anonymously.")
            }
            guard let user = authResult?.user else { return }

            // Store the UID that identifies the user. This will be used to define
            // the file path for chats in Firestore and files in Firebase Storage
            // that are accessible by the user and the admin(s).
            UserDefaults.standard.set(user.uid, forKey: "uid")
            logger.info("Anonymous login UID: \(user.uid)")
        }
    }
}
