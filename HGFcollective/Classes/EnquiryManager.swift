//
//  EnquiryManager.swift
//  HGF Collective
//
//  Created by William Dolke on 16/09/2022.
//

import Foundation
import FirebaseFirestore
import FirebaseCrashlytics

class EnquiryManager: ObservableObject {
    // Singleton
    static let shared = EnquiryManager()

    @Published var chat: Chat?
    @Published var mail = Mail(recipients: [], problemReportRecipients: [])

    // Create an instance of our Firestore database
    let firestoreDB = Firestore.firestore()

    // On initialisation of the EnquiryManager class, get the chat and
    // email enquiries contact information from Firestore
    init() {
        let collection = "enquiries"
        // Set to high priority to minimise the time we wait for data.
        // We don't necessarily need to load this in advance as users
        // are not likely to enquire by email frequently.
        Task(priority: .high) {
            // Fetch the chat title name and icon, this allows admins to
            // override the built in chat name/icon from the database
            logger.info("Retrieving chat enquiry information.")
            if let chatInfo: Chat = await self.getEnquiryInfo(collection: collection, document: "chat") {
                self.chat = chatInfo
            }

            // Fetch the email recipients and email subject + body templates
            logger.info("Retrieving email enquiry information.")
            if let mailInfo: Mail = await self.getEnquiryInfo(collection: collection, document: "email") {
                self.mail = mailInfo
            }
        }
    }

    // Read a document from a collection in Firestore and convert to a generic type
    private func getEnquiryInfo<T: Codable>(collection: String, document: String) async -> T? {
        do {
            let document = try await firestoreDB.collection(collection).document(document).getDocument()

            // Convert the document to the model
            if let data = try? document.data(as: T.self) {
                logger.info("Successfully decoded document to \(T.self).")
                return data
            } else {
                logger.error("Error decoding document to \(T.self).")
            }
            return nil
        } catch {
            Crashlytics.crashlytics().record(error: error)
            logger.error("Error fetching \(T.self) enquiry information: \(error)")
            return nil
        }
    }
}
