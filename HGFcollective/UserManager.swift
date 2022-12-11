//
//  UserManager.swift
//  HGF Collective
//
//  Created by William Dolke on 26/09/2022.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserManager: ObservableObject {
    @Published private(set) var users: [User] = []

    // Create an instance of our Firestore database
    let firestoreDB = Firestore.firestore()

    // On initialisation of the UserManager class, get the users from Firestore
    init() {
        self.getUsers()
    }

    /// Fetch all user documents from the database
    func getUsers() {
        // Read users from Firestore in real-time with the addSnapShotListener
        firestoreDB.collection("users").addSnapshotListener { querySnapshot, error in

            // If we don't have documents, exit the function
            guard let documents = querySnapshot?.documents else {
                logger.error("Error fetching user documents: \(String(describing: error))")
                return
            }

            // Map the documents to User instances
            self.users = documents.compactMap { document -> User? in
                do {
                    // Convert each document into the User model
                    return try document.data(as: User.self)
                } catch {
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
    func sortUsers() {
        self.users.sort(by: { $0.latestTimestamp > $1.latestTimestamp })
    }
}
