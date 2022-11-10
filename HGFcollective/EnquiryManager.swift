//
//  EnquiryManager.swift
//  HGF Collective
//
//  Created by William Dolke on 16/09/2022.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class EnquiryManager: ObservableObject {
    @Published var chat: Chat
    @Published var mail: Mail

    // Create an instance of our Firestore database
    let firestoreDB = Firestore.firestore()

    // On initialisation of the EnquiryManager class, get the chat and mail enquiry contact information from Firestore
    init() {
        self.chat = Chat(name: "", iconURL: "")
        self.mail = Mail(recipients: [])

        Task(priority: .high) {
            await self.getMailEnquiryInfo()
        }
    }

    func getMailEnquiryInfo() async {
        do {
            let document = try await firestoreDB.collection("enquiries").document("email").getDocument()

            if let mailInfo = try? document.data(as: Mail.self) {
                DispatchQueue.main.async {
                    self.mail = mailInfo
                }
            }
        } catch {
            logger.info("Error fetching email enquiry information: \(error)")
        }
    }
}
