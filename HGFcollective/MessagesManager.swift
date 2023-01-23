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
    @Published private(set) var lastMessageId: String = ""
    @Published var isCustomer: Bool
    var uid: String = ""

    // Create an instance of our Firestore database and Firebase Storage
    let firestoreDB = Firestore.firestore()
    let storage = Storage.storage()

    init(uid: String, isCustomer: Bool = true) {
        self.uid = uid
        self.isCustomer = isCustomer

        // On initialisation of the MessagesManager class, get the messages
        // for a particular user id from Firestore
        self.getMessages()

        // Get the user document
        Task(priority: .high) {
            await self.getUser()
        }
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

            // Sort the messages by sent date
            self.messages.sort { $0.timestamp < $1.timestamp }

            // Get the ID of the last message so we can automatically scroll to it in ChatView
            if let id = self.messages.last?.id {
                self.lastMessageId = id
            }
        }
    }

    /// Retrieve user document from  the Firestore database
    private func getUser() async {
        do {
            let document = try await firestoreDB.collection("users").document(uid).getDocument()

            // Convert the document into the User model
            if let user = try? document.data(as: User.self) {
                DispatchQueue.main.async {
                    self.user = user
                }
            }
        } catch {
            Crashlytics.crashlytics().record(error: error)
            logger.info("Error fetching user document: \(error)")
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
                                     type: type)
            // Also update the user document with a preview of the latest message
            let userUpdate = User(id: uid,
                                  messagePreview: String(text.prefix(30)),
                                  latestTimestamp: date,
                                  read: false,
                                  sender: UserDefaults.standard.value(forKey: "uid") as! String)

            // Create a new document in Firestore with the newMessage and userUpdate variable
            // above. Use setData(from:) to convert the Message properties into document fields.
            try firestoreDB.collection("users").document(uid).collection("messages").document(messageID)
                .setData(from: newMessage)
            logger.info("Successfully sent chat message to database.")

            try firestoreDB.collection("users").document(uid)
                .setData(from: userUpdate)
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

    /// Set messages as read, locally and in Firestore
    func setAsRead() {
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
    }
}
