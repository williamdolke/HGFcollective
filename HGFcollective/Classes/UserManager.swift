//
//  UserManager.swift
//  HGF Collective
//
//  Created by William Dolke on 26/09/2022.
//

import Foundation
import FirebaseFirestore
import FirebaseCrashlytics
import FirebaseFirestoreSwift

class UserManager: ObservableObject {
    @Published private(set) var users: [User] = []
    // The cumulative unread messages count for all users
    var unreadMessages: Int = 0
    var listener: ListenerRegistration?

    // Create an instance of our Firestore database
    let firestoreDB = Firestore.firestore()

    // On initialisation of the UserManager class, get the users from Firestore
    init() {
        self.getUsers()
    }

    /// Fetch all user documents from the database
    private func getUsers() {
        // Read users from Firestore in real-time with the addSnapShotListener
        listener = firestoreDB.collection("users").addSnapshotListener { querySnapshot, error in

            // If we don't have documents, exit the function
            guard let documents = querySnapshot?.documents else {
                Crashlytics.crashlytics().record(error: error!)
                logger.error("Error fetching user document: \(String(describing: error))")
                return
            }

            // Map the documents to User instances
            self.users = documents.compactMap { document -> User? in
                do {
                    // Convert each document into the User model
                    return try document.data(as: User.self)
                } catch {
                    Crashlytics.crashlytics().record(error: error)
                    logger.error("Error decoding document into User: \(error)")

                    // Return nil if we run into an error - the compactMap will
                    // not include it in the final array
                    return nil
                }
            }
            self.sortUsers()
        }
    }

    /// Sort users by the timestamp of their most recent messages
    private func sortUsers() {
        self.users.sort(by: { $0.latestTimestamp > $1.latestTimestamp })
    }
}