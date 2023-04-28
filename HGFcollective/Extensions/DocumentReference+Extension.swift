//
//  DocumentReference+Extension.swift
//  HGFcollective
//
//  Created by William Dolke on 27/04/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseCrashlytics

extension DocumentReference {
    /// Delete a document and it's subcollection documents. This isn't recursive so will only delete documents
    /// in the subcollection, not subcollections contained within the subcollection etc.
    func deleteDocumentAndSubcollectionDocuments(collection: String, documentId: String, subCollection: String) {
        // Delete the document
        self.delete { error in
            if let error = error {
                logger.error("Error deleting document: \(error)")
                return
            }

            // Delete the subcollection
            self.collection(subCollection).getDocuments { (snapshot, error) in
                if let error = error {
                    Crashlytics.crashlytics().record(error: error)
                    logger.error("Error retrieving subcollection documents: \(String(describing: error))")
                    return
                } else if let snapshot = snapshot {
                    for document in snapshot.documents {
                        document.reference.delete()
                    }
                }
            }
        }
    }
}
