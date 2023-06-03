//
//  UserManager.swift
//  HGF Collective
//
//  Created by William Dolke on 26/09/2022.
//

import Foundation
import FirebaseCrashlytics
import FirebaseFirestore

class UserManager: ObservableObject {
    @Published private(set) var users: [User] = []
    @Published private(set) var messagesManagers: [String: MessagesManager] = [:]
    let notificationName: String = "AdminUnreadMessageCountChanged"
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
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                logger.error("Error fetching user document: \(error)")
                return
            }

            // Map the documents to User instances
            self.users = (querySnapshot?.decodeDocuments() ?? []) as [User]
            self.sortUsers()
            self.getMessagesManagers()
        }
    }

    /// Sort users by the timestamp of their most recent messages
    private func sortUsers() {
        logger.info("Sorting \(users.count) users.")
        self.users.sort(by: { $0.latestTimestamp > $1.latestTimestamp })
    }

    /// Initialise a messagesManager for each user
    private func getMessagesManagers() {
        logger.info("Getting message managers for \(users.count) users.")
        for user in users {
            if !messagesManagers.keys.contains(user.id) {
                logger.info("Getting message manager for user.")
                messagesManagers[user.id] = MessagesManager(uid: user.id,
                                                            isCustomer: false)
            } else {
                logger.info("No message manager found for user.")
            }
        }
    }

    /// Calculate and store the number of unread messages from all users
    func countUnreadMessages() {
        logger.info("Calculating unread messages from all users.")

        var counter = 0
        for manager in messagesManagers.values {
            counter += manager.unreadMessages
        }

        if counter != unreadMessages {
            logger.info("Setting unread message count to \(counter).")
            // This needs to be completed before the notification is posted below.
            unreadMessages = counter

            NotificationCenter.default.post(name: Notification.Name(notificationName), object: nil)
        }
    }

    /// Store the preferred name for the customer that the admin has entered.
    /// This is used in place of the customer's uid in UI elements such as in the inboxView as well as in notifications.
    func storePreferredName(name: String, id: String) {
        firestoreDB.collection("users").document(id)
            .setData(["preferredName": name], merge: true) { error in
                if let error = error {
                    Crashlytics.crashlytics().record(error: error)
                    logger.error("Error sending preferredName to Firestore: \(error)")
                } else {
                    logger.info("Successfully sent preferredName to database.")
                }
            }
    }
}
