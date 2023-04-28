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
        return documents.compactMap { document in
            do {
                return try document.data(as: T.self)
            } catch {
                Crashlytics.crashlytics().record(error: error)
                logger.error("Error decoding document into \(T.self): \(error)")

                // Return nil if we run into an error - the compactMap will
                // not include it in the final array
                return nil
            }
        }
    }
}
