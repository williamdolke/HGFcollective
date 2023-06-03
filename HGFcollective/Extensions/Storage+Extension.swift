//
//  Storage+Extension.swift
//  HGFcollective
//
//  Created by William Dolke on 02/06/2023.
//

import Foundation
import FirebaseStorage

extension Storage {
    func deleteFolderContents(folder: String) {
        let storageRef = self.reference()
        let folderRef = storageRef.child(folder)

        folderRef.deleteFolderContents()
    }
}
