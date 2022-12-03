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

    func getUsers() {
        firestoreDB.collection("users").addSnapshotListener { querySnapshot, error in

            // If we don't have documents, exit the function
            guard let documents = querySnapshot?.documents else {
                logger.error("Error fetching user documents: \(String(describing: error))")
                return
            }

            // Mapping through the documents
            self.users = documents.compactMap { document -> User? in
                do {
                    // Converting each document into the User model
                    // Note that data(as:) is a function available only in FirebaseFirestoreSwift package
                    return try document.data(as: User.self)
                } catch {
                    logger.error("Error decoding document into User: \(error)")

                    // Return nil if we run into an error - but the compactMap will not include it in the final array
                    return nil
                }
            }
            self.sortUsers()
        }
    }

    func sortUsers() {
        self.users.sort(by: { $0.latestTimestamp > $1.latestTimestamp })
    }
}