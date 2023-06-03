//
//  Firestore+Extension.swift
//  HGFcollective
//
//  Created by William Dolke on 31/05/2023.
//

import Foundation
import FirebaseFirestore

extension Firestore {
    // Check if a document already exists in the Firestore database
    func checkDocumentExists(docPath: String, completion: @escaping (Bool, Error?) -> Void) {
        let docRef = document(docPath)

        docRef.getDocument { (document, error) in
            if let error = error {
                completion(false, error)
            } else if let document = document, document.exists {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }

    func deleteDocument(docPath: String, completion: @escaping (Error?) -> Void) {
        let docRef = document(docPath)

        docRef.delete { error in
            completion(error)
        }
    }

    func deleteDocumentAndSubcollectionDocuments(collection: String,
                                                 documentId: String,
                                                 subCollection: String) {
        let documentRef = self.collection(collection).document(documentId)

        documentRef.deleteDocumentAndSubcollectionDocuments(collection: collection,
                                                            documentId: documentId,
                                                            subCollection: subCollection)
    }
}
