//
//  QuerySnapshot+Extension.swift
//  HGFcollective
//
//  Created by William Dolke on 28/04/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseCrashlytics

extension QuerySnapshot {
    /// Decode  documents to an array of instances of a generic type
    func decodeDocuments<T: Codable>() -> [T] {
        logger.info("Attempting to decode documents to \(T.self).")
        return documents.compactMap { document in
            do {
                return try document.data(as: T.self)
            } catch {
                logger.error("Error decoding document into \(T.self): \(error)")
                Crashlytics.crashlytics().record(error: error)

                // Return nil if we run into an error - the compactMap will
                // not include it in the final array
                return nil
            }
        }
    }
}
