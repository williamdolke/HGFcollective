//
//  MessagesManager.swift
//  HGF Collective
//
//  Created by William Dolke on 12/09/2022.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseCrashlytics
import FirebaseFirestoreSwift

class MessagesManager: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published private(set) var user: User?
    @Published private(set) var latestMessageId: String = ""
    // Identifies whether a view is being presented to a user or an admin
    @Published var isCustomer: Bool
    let notificationName: String
    // Customer uid
    var uid: String = ""
    // The unread message count for this user
    var unreadMessages: Int = 0

    // Create an instance of our Firestore database (for messages) and Firebase Storage (for images)
    let firestoreDB = Firestore.firestore()
    let storage = Storage.storage()

    init(uid: String, isCustomer: Bool = true, notificationName: String) {
        self.uid = uid
        self.isCustomer = isCustomer
        self.notificationName = notificationName

        // On initialisation of the MessagesManager class, get the messages
        // for a particular customer uid from Firestore and count the number of
        // messages that the local user hasn't read
        self.getMessages()

        self.getUser()
    }

    /// Retrieve messages from  the Firestore database
    private func getMessages() {
        // Read message from Firestore in real-time with the addSnapShotListener
        firestoreDB.collection("users").document(uid).collection("messages")
            .addSnapshotListener { querySnapshot, error in
                // If we don't have documents, exit the function
                guard let documents = querySnapshot?.documents else {
                    Crashlytics.crashlytics().record(error: error!)
                    logger.error("Error fetching documents: \(String(describing: error))")
                    return
                }

                // Map the documents to Message instances
                self.messages = documents.compactMap { document -> Message? in
                    do {
                        // Convert each document into the Message model
                        return try document.data(as: Message.self)
                    } catch {
                        Crashlytics.crashlytics().record(error: error)
                        logger.error("Error decoding document into Message: \(error)")

                        // Return nil if we run into an error - the compactMap will
                        // not include it in the final array
                        return nil
                    }
                }

                // Sort the messages by sent date and count the number of
                // messages that the local user hasn't read
                self.messages.sort { $0.timestamp < $1.timestamp }
                self.countUnreadMessages()

                // Get the ID of the last message so we can automatically scroll to it in ChatView
                if let id = self.messages.last?.id {
                    self.latestMessageId = id
                }
        }
    }

    /// Retrieve user document from  the Firestore database
    private func getUser() {
        // Read message from Firestore in real-time with the addSnapShotListener
        firestoreDB.collection("users").document(uid)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    Crashlytics.crashlytics().record(error: error!)
                    logger.error("Error fetching user document: \(String(describing: error))")
                    return
                }

                do {
                    self.user = try document.data(as: User.self)
                } catch {
                    logger.error("Error decoding document into User: \(String(describing: error))")
                }
        }
    }

    /// Add a message to the Firestore database
    func sendMessage(text: String, type: String) {
        do {
            // Create a new Message instance, with a unique ID, the text we passed,
            // a received value and a timestamp
            let date = Date()
            let messageID = UUID().uuidString
            let newMessage = Message(id: messageID,
                                     content: text,
                                     isCustomer: isCustomer,
                                     timestamp: date,
                                     type: type,
                                     read: false)

            // Also update the user document with a preview of the most recent message
            let userUpdate = User(id: uid,
                                  messagePreview: String(text.prefix(30)),
                                  latestTimestamp: date,
                                  read: false,
                                  // swiftlint:disable force_cast
                                  sender: UserDefaults.standard.value(forKey: "uid") as! String)
                                  // swiftlint:enable force_cast

            // Create a new document in Firestore with the newMessage and userUpdate variable
            // above. Use setData(from:) to convert the Message properties into document fields.
            try firestoreDB.collection("users").document(uid).collection("messages").document(messageID)
                .setData(from: newMessage)
            logger.info("Successfully sent chat message to database.")

            try firestoreDB.collection("users").document(uid)
                .setData(from: userUpdate, merge: true)
            logger.info("Successfully sent update to user document.")
        } catch {
            Crashlytics.crashlytics().record(error: error)
            logger.error("Error adding message to Firestore: \(error)")
        }
    }

    /// Add an image to the Firestore database
    func sendImage(image: UIImage) {
        let storagePath = "users/" + uid + "/" + UUID().uuidString
        let ref = Storage.storage().reference(withPath: storagePath)

        // Convert the image to jpeg format and compress
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }

        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                logger.error("Failed to push image to Storage: \(error)")
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    Crashlytics.crashlytics().record(error: error)
                    logger.error("Failed to retrieve downloadURL: \(error)")
                    return
                }
                logger.info("Successfully stored image with url: \(url?.absoluteString ?? "")")
                self.sendMessage(text: url!.absoluteString, type: "image")
            }
        }
    }

    /// Set the most recent message as read, locally and in Firestore
    func setAsRead() {
        logger.info("Setting latest message as read.")

        // Update the user document in Firestore
        firestoreDB.collection("users").document(uid)
            .updateData(["read": true]) { error in
                if let error = error {
                    Crashlytics.crashlytics().record(error: error)
                    logger.error("Error setting message as read in Firestore: \(error)")
                } else {
                    logger.info("Successfully set message as read.")
                }
            }

        // Update the message document for the latest message
        firestoreDB.collection("users").document(uid).collection("messages").document(latestMessageId)
            .updateData(["read": true]) { error in
                if let error = error {
                    Crashlytics.crashlytics().record(error: error)
                    logger.error("Error setting message as read in Firestore: \(error)")
                } else {
                    logger.info("Successfully set message as read.")
                }
            }
    }

    /// Count and store the number of unread messages from this user
    func countUnreadMessages() {
        logger.info("Counting unread messages.")

        var counter = 0
        for idx in stride(from: messages.count-1, through: 0, by: -1) {
            // Working backwards from the most recent message, if the message wasn't sent
            // by us and hasn't been read then increment the unread message count
            if messages[idx].isCustomer != isCustomer && messages[idx].read == false {
                counter += 1
            } else {
                // Stop when we find a message we sent or a message we have read
                break
            }
        }

        if counter != unreadMessages {
            unreadMessages = counter
            logger.info("Setting unread message count to \(unreadMessages).")

            NotificationCenter.default.post(name: Notification.Name(notificationName),
                                            object: unreadMessages)
        }
    }
}
