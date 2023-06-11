//
//  LoginUtils.swift
//  HGFcollective
//
//  Created by William Dolke on 15/04/2023.
//

import Foundation
import FirebaseAuth
import FirebaseAnalytics
import FirebaseFirestore
import FirebaseCrashlytics

/// Firebase login functionality/utilities
struct LoginUtils {
    /// The closure parameter allows us to optionally pass a closure block, allowing us to execute
    /// additional code after a successful login.
    static func signInAnonymously(closure: (() -> Void)? = nil) {
        logger.info("Attempting to authenticate anonymously.")

        if UserDefaults.standard.string(forKey: "uid") == nil {
            // Sign the user in to Firestore anonymously
            Auth.auth().signInAnonymously { authResult, error in
                if let error = error {
                    Crashlytics.crashlytics().record(error: error)
                    logger.error("Error authenticating anonymously: \(error)")
                } else {
                    Analytics.logEvent(AnalyticsEventLogin, parameters: [AnalyticsParameterMethod: "Anonymous"])
                    logger.info("Sucessfully signed in anonymously.")
                }
                guard let user = authResult?.user else { return }

                // Store the UID that identifies the user. This will be used to define
                // the file path for chats in Firestore and files in Firebase Storage
                // that are accessible by the user and the admin(s).
                UserDefaults.standard.set(user.uid, forKey: "uid")
                logger.info("Anonymous login UID: \(user.uid)")

                if let closure = closure {
                    closure()
                }
            }
        }
    }

    /// Sign an admin out of Firestore
    static func signAdminOut() {
        logger.info("Logging out of Firebase admin account.")
        do {
            deleteFCMtoken()

            try Auth.auth().signOut()

            UserDefaults.standard.set(nil, forKey: "uid")
            UserDefaults.standard.set(nil, forKey: "isAdmin")
        } catch let signOutError as NSError {
            Crashlytics.crashlytics().record(error: signOutError)
            logger.error("Error signing out as admin: \(signOutError)")
        }
        logger.info("Successfully logged out as admin.")
    }

    /// Store the FCM token in the Firestore database. The location depends on whether the user is
    /// a customer or an admin.
    static func storeFCMtoken(token: String?) {
        logger.info("Attempting to store FCM token.")

        // We need to know the customer's/admin's id in order to store the FCM token in the database.
        // However, if we don't know it yet e.g. on the first launch of the app we may receive the FCM
        // token before the Firebase UID. To handle this, wait for a small period of time and attempt
        // to store the FCM token again.
        if let uid = UserDefaults.standard.value(forKey: "uid") as? String, let token = token {
            let firestoreDB = Firestore.firestore()

            if (UserDefaults.standard.value(forKey: "isAdmin") != nil) {
                // Upload to the admin collection
                let documentData: [String: [String: String]] = ["token": [uid: token]]

                firestoreDB.collection("admin").document("fcmToken")
                    .setData(documentData, merge: true) { error in
                        if let error = error {
                            Crashlytics.crashlytics().record(error: error)
                            logger.error("Error sending admin FCM token to Firestore: \(error)")
                        } else {
                            logger.info("Successfully sent admin FCM token to database.")
                        }
                    }
            } else {
                // Upload to the users collection
                let documentData: [String: String] = ["fcmToken": token]

                firestoreDB.collection("users").document(uid)
                    .setData(documentData, merge: true) { error in
                        if let error = error {
                            Crashlytics.crashlytics().record(error: error)
                            logger.error("Error sending FCM token to Firestore: \(error)")
                        } else {
                            logger.info("Successfully sent FCM token to database.")
                        }
                    }
            }
        } else {
            // Wait for a second before trying to store the FCM token again, hopefully we will
            // know our uid by then.
            let delayInSeconds = 1.0
            logger.error("Failed to retrieve uid, waiting for \(delayInSeconds) to retry.")
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                storeFCMtoken(token: token)
            }
        }
    }

    /// Delete the customer/admin FCM token from the database
    static func deleteFCMtoken() {
        logger.info("Attempting to delete FCM token.")

        // Nullify the FCM token in the database before we sign out and before the uid is nullified
        if let uid = UserDefaults.standard.value(forKey: "uid") as? String {
            if (UserDefaults.standard.value(forKey: "isAdmin") != nil) {
                // Remove only this admin's FCM token from the map in the document
                let field = "token.\(uid)"
                let documentData = [field: FieldValue.delete()]
                Firestore.firestore().collection("admin").document("fcmToken").updateData(documentData) { error in
                    if let error = error {
                        logger.error("Error deleting admin FCM token: \(error)")
                    } else {
                        logger.info("Admin FCM token successfully deleted.")
                    }
                }
            } else {
                // Remove the FCM token from the customer's user document
                let field = "fcmToken"
                let documentData = [field: FieldValue.delete()]
                Firestore.firestore().collection("users").document(uid).updateData(documentData) { error in
                    if let error = error {
                        logger.error("Error deleting FCM token: \(error)")
                    } else {
                        logger.info("FCM token successfully deleted.")
                    }
                }
            }
        }
    }
}
