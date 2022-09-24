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
    @Published var mail: Mail
    
    // Create an instance of our Firestore database
    let db = Firestore.firestore()
    
    init() {
        self.mail = Mail(recipients: [])
        Task(priority: .high) {
            await self.getEnquiryInfo()
        }
    }
    
    func getEnquiryInfo() async {
        do {
            let document = try await db.collection("enquiries").document("email").getDocument()
            
            if let mailInfo = try? document.data(as: Mail.self) {
                DispatchQueue.main.async {
                    self.mail = mailInfo
                }
            }
        } catch {
            print(error)
        }
    }
}
