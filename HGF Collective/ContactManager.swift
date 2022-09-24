//
//  ContactManager.swift
//  ArtApp
//
//  Created by William Dolke on 17/09/2022.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class ContactManager: ObservableObject {
    @Published var contact: Contact
    
    // Create an instance of our Firestore database
    let db = Firestore.firestore()
    
    init() {
        self.contact = Contact(name: "", imageURL: "")
        Task(priority: .high) {
            await self.getContactInfo()
        }
    }
    
    func getContactInfo() async {
        do {
            let document = try await db.collection("enquiries").document("chat").getDocument()
            
            if let contactInfo = try? document.data(as: Contact.self) {
                DispatchQueue.main.async {
                    self.contact = contactInfo
                }
            }
        } catch {
            print(error)
        }
    }
}

