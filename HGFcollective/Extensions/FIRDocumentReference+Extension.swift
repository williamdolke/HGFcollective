//
//  DocumentReference+Extension.swift
//  HGFcollective
//
//  Created by William Dolke on 27/04/2023.
//

import Foundation
import FirebaseFirestore

extension DocumentReference {
    /// 
    func deleteDocumentWithSubcolllection(collection: String, documentId: String, subCollection: String) {
        // Delete the document itself
        self.delete { error in
            if let error = error {
                logger.error("Error deleting document: \(error)")
                return
            }

            // Delete all subcollections
            self.collection(subCollection).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else {
                    logger.error("Error retrieving subcollections: \(String(describing: error))")
                    return
                }

                for document in snapshot.documents {
                    document.reference.delete()
                }
            }
        }
    }
}
