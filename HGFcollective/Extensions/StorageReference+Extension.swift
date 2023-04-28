//
//  StorageReference+Extension.swift
//  HGFcollective
//
//  Created by William Dolke on 27/04/2023.
//

import Foundation
import FirebaseStorage
import FirebaseCrashlytics

extension StorageReference {
    /// Delete the each file/folder contained in a folder in Firebase Storage
    func deleteFolderContents() {
        // List the contents of the folder and delete each individual file/folder.
        // The folder will cease to exist once it has no contents.
        self.listAll { (result, error) in
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                logger.error("Error listing files in storage: \(error)")
            } else if let result = result {
                for file in result.items {
                    file.delete { error in
                        if let error = error {
                            Crashlytics.crashlytics().record(error: error)
                            logger.error("Error deleting \(file) from storage: \(error)")
                        } else {
                            logger.info("\(file) successfully deleted from storage.")
                        }
                    }
                }
            }
        }
    }
}