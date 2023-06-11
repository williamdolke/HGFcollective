//
//  Storage+Extension.swift
//  HGFcollective
//
//  Created by William Dolke on 02/06/2023.
//

import Foundation
import FirebaseStorage
import FirebaseCrashlytics

extension Storage {
    func deleteFolderContents(folder: String) {
        let storageRef = self.reference()
        let folderRef = storageRef.child(folder)

        folderRef.deleteFolderContents()
    }

    /// Delete multiple files from their URLs
    func deleteFiles(atURLs urls: [String]) {
        for url in urls {
            // Check if the URL is for Firebase Storage
            if isValidURL(url) {
                let storageRef = self.reference(forURL: url)
                // Delete the image from Firebase Storage
                storageRef.delete { error in
                    if let error = error {
                        logger.error("Failed to delete file from Storage at \(url) with error: \(error)")
                    } else {
                        logger.info("File deleted successfully from Storage at \(url)")
                    }
                }
            } else {
                logger.info("Invalid Firebase Storage URL: \(url)")
            }
        }
    }

    // Check if a URL is of the following format:
    // http[s]://<host>/v0/b/<bucket>/o/<path/to/object>[?token=signed_url_params]
    private func isValidURL(_ url: String) -> Bool {
        let regexPattern = #"^https?://[^/]+/v0/b/[^/]+/o/[^?]+$"#
        let regex = try? NSRegularExpression(pattern: regexPattern)

        let range = NSRange(location: 0, length: url.utf16.count)
        let matches = regex?.matches(in: url, options: [], range: range)

        return !(matches?.isEmpty ?? true)
    }

    /// Store data at a specified path
    func uploadData(path: String, data: Data, completion: @escaping (String?) -> Void) {
        let storageRef = self.reference(withPath: path)

        storageRef.putData(data, metadata: nil) { _, error in
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                logger.error("Failed to upload data to Storage: \(error)")
                completion(nil)
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    Crashlytics.crashlytics().record(error: error)
                    logger.error("Failed to retrieve URL of stored data: \(error)")
                    completion(nil)
                    return
                }
                logger.info("Successfully stored data in Storage with URL: \(url?.absoluteString ?? "")")
                // Pass the url of the image in the database as a parameter to the completion handler
                completion(url?.absoluteString)
            }
        }
    }
}
