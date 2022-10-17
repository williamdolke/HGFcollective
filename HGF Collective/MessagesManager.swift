//
//  MessagesManager.swift
//  HGF Collective
//
//  Created by William Dolke on 12/09/2022.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

class MessagesManager: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published private(set) var lastMessageId: String = ""
    @Published var isCustomer: Bool
    var uid: String = ""

    // Create an instance of our Firestore database
    let firestoreDB = Firestore.firestore()
    let storage = Storage.storage()

    // On initialisation of the MessagesManager class, get the messages for a particular user id from Firestore
    init(uid: String, isCustomer: Bool = true) {
        self.uid = uid
        self.isCustomer = isCustomer
        self.getMessages()
    }

    // Read message from Firestore in real-time with the addSnapShotListener
    func getMessages() {
        firestoreDB.collection("users").document(uid).collection("messages")
            .addSnapshotListener { querySnapshot, error in

            // If we don't have documents, exit the function
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }

            // Mapping through the documents
            self.messages = documents.compactMap { document -> Message? in
                do {
                    // Converting each document into the Message model
                    // Note that data(as:) is a function available only in FirebaseFirestoreSwift package
                    return try document.data(as: Message.self)
                } catch {
                    // If we run into an error, print the error in the console
                    print("Error decoding document into Message: \(error)")

                    // Return nil if we run into an error - but the compactMap will not include it in the final array
                    return nil
                }
            }

            // Sorting the messages by sent date
            self.messages.sort { $0.timestamp < $1.timestamp }

            // Getting the ID of the last message so we automatically scroll to it in ChatView
            if let id = self.messages.last?.id {
                self.lastMessageId = id
            }
        }
    }

    // Add a message in Firestore
    func sendMessage(text: String, type: String) {
        do {
            // Create a new Message instance, with a unique ID, the text we passed, a received value and a timestamp
            let date = Date()
            let messageID = UUID().uuidString
            let newMessage = Message(id: messageID,
                                     content: text,
                                     isCustomer: isCustomer,
                                     timestamp: date,
                                     type: type)
            let userUpdate = User(id: uid,
                                  messagePreview: String(text.prefix(30)),
                                  latestTimestamp: date)

            // Create a new document in Firestore with the newMessage and userUpdate variable above, and use
            // setData(from:) to convert the Message into Firestore data
            // Note that setData(from:) is a function available only in FirebaseFirestoreSwift package - remember to
            // import it at the top
            try firestoreDB.collection("users").document(uid).collection("messages").document(messageID)
                .setData(from: newMessage)
            print("Successfully sent message to database.")

            try firestoreDB.collection("users").document(uid)
                .setData(from: userUpdate)
            print("Successfully sent update to user.")
        } catch {
            // If we run into an error, print the error in the console
            print("Error adding message to Firestore: \(error)")
        }
    }
    
    // Add an image in Firestore
    func sendImage(image: UIImage) {
        let imageID = UUID().uuidString
        let ref = Storage.storage().reference(withPath: imageID)
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                print("Failed to push image to Storage: \(err)")
                return
            }
            ref.downloadURL { url, err in
                if let err = err {
                    print("Failed to retrieve downloadURL: \(err)")
                    return
                }
                print("Successfully stored image with url: \(url?.absoluteString ?? "")")
            }
            
            self.sendMessage(text: imageID, type: "image")
        }
    }
}
