//
//  EnquiryManager.swift
//  HGF Collective
//
//  Created by William Dolke on 16/09/2022.
//

import Foundation
import FirebaseFirestore
import FirebaseCrashlytics
import FirebaseFirestoreSwift

class EnquiryManager: ObservableObject {
    @Published var chat: Chat?
    @Published var mail: Mail

    // Create an instance of our Firestore database
    let firestoreDB = Firestore.firestore()

    // On initialisation of the EnquiryManager class, get the chat and
    // email enquiries contact information from Firestore
    init() {
        self.mail = Mail(recipients: [])

        // Set to high priority to minimise the time we wait for data.
        // We don't necessarily need to load this in advance as users
        // are not likely to enquire by email frequently.
        Task(priority: .high) {
            await self.getChatEnquiryInfo()
            await self.getMailEnquiryInfo()
        }
    }

    /// Fetch the email recipients and email subject + body templates
    private func getMailEnquiryInfo() async {
        do {
            let document = try await firestoreDB.collection("enquiries").document("email").getDocument()

            // Convert the document into the Mail model
            if let mailInfo = try? document.data(as: Mail.self) {
                DispatchQueue.main.async {
                    self.mail = mailInfo
                }
            }
        } catch {
            Crashlytics.crashlytics().record(error: error)
            logger.error("Error fetching email enquiry information: \(error)")
        }
    }

    /// Fetch the chat title name and icon, this allows admins to override the built in name/icon from the database
    private func getChatEnquiryInfo() async {
        do {
            let document = try await firestoreDB.collection("enquiries").document("chat").getDocument()

            // Convert the document into the Chat model
            if let chatInfo = try? document.data(as: Chat.self) {
                DispatchQueue.main.async {
                    self.chat = chatInfo
                }
            }
        } catch {
            Crashlytics.crashlytics().record(error: error)
            logger.error("Error fetching chat enquiry information: \(error)")
        }
    }
}
