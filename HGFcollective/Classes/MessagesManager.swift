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
    @Published var messages: [Message] = []
    @Published var user: User?
    @Published var latestMessageId: String = ""
    // Identifies whether a view is being presented to a user or an admin
    let isCustomer: Bool
    private let notificationName: String = "UnreadMessageCountChanged"
    // Customer uid
    var uid: String = ""
    // The unread message count for this user
    var unreadMessages: Int = 0

    private var messagesListener: ListenerRegistration?
    private var userListener: ListenerRegistration?

    // Create an instance of our Firestore database (for messages) and Firebase Storage (for images)
    private let firestoreDB = Firestore.firestore()
    private let storage = Storage.storage()

    init(uid: String, isCustomer: Bool = true) {
        self.uid = uid
        self.isCustomer = isCustomer

        // On initialisation of the MessagesManager class, get the messages
        // for a particular customer uid from Firestore and count the number of
        // messages that the local user hasn't read
        self.getMessages()

        self.getUser()
    }

    /// Retrieve messages from the Firestore database
    private func getMessages() {
        logger.info("Retrieving chat history from database.")

        // Read message from Firestore in real-time with the addSnapShotListener
        messagesListener = firestoreDB.collection("users").document(uid).collection("messages")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    Crashlytics.crashlytics().record(error: error)
                    logger.error("Error fetching message documents: \(error)")
                    return
                }

                // Map the documents to Message instances
                self.messages = (querySnapshot?.decodeDocuments() ?? []) as [Message]

                self.sortMessages()
                self.countUnreadMessages()

                // Get the ID of the last message so we can automatically scroll to it in ChatView
                if let id = self.messages.last?.id {
                    self.latestMessageId = id
                }
        }
    }

    /// Retrieve user document from the Firestore database
    private func getUser() {
        logger.info("Retrieving user document from database.")

        // Read message from Firestore in real-time with the addSnapShotListener
        userListener = firestoreDB.collection("users").document(uid)
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

    /// Add a new chat message to the Firestore database
    func sendMessage(text: String, type: String) {
        do {
            logger.info("Sending new chat message to database.")

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
                                  // swiftlint:disable:next force_cast
                                  sender: UserDefaults.standard.value(forKey: "uid") as! String,
                                  isCustomer: isCustomer)

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

    /// Upload an image to Firebase storage
    func sendImage(image: UIImage) {
        logger.info("Sending new chat image to database.")

        // Create the path where the image will be stored in storage
        let storagePath = "users/" + uid + "/" + UUID().uuidString

        // Convert the image to jpeg format and compress
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }

        Storage.storage().uploadData(path: storagePath, data: imageData) { storageURL in
            if let storageURL = storageURL {
                logger.info("Sending message after successfully storing image at URL: \(storageURL)")
                self.sendMessage(text: storageURL, type: "image")
            } else {
                logger.error("Failed to send message after storing image.")
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

        // Clear notifications for the specified category.
        let categoryIdentifier = user?.id
        // The cloud function script uses the customer's uid as the categoryIdentifier.
        // This means that the customer and admin can use the same category identifier
        // to clear notification for a particular conversation.
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            let identifiers = notifications
                .filter { $0.request.content.categoryIdentifier == categoryIdentifier }
                .map { $0.request.identifier }
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
        }
    }

    /// Sort the messages by sent date and count the number of messages that the local user hasn't read
    private func sortMessages() {
        logger.info("Sorting \(messages.count) messages.")
        self.messages.sort { $0.timestamp < $1.timestamp }
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
            logger.info("Setting unread message count to \(counter).")
            // This needs to be completed before the notification is posted below.
            unreadMessages = counter

            NotificationCenter.default.post(name: Notification.Name(notificationName), object: nil)
        }
    }

    /// Clean up after signing out
    func cleanup() {
        self.messages = []
        self.user = nil
        self.latestMessageId = ""
        self.uid = ""
        self.unreadMessages = 0
        // Stop listening for database changes
        self.messagesListener?.remove()
        self.userListener?.remove()
    }

    /// When we authenticate anonymously and have previously been anonymously
    /// authenticated we need to update these variables
    func refresh(uid: String) {
        self.uid = uid
        self.getUser()
        self.getMessages()
    }
}
