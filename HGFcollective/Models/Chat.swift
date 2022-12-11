//
//  Chat.swift
//  HGF Collective
//
//  Created by William Dolke on 17/09/2022.
//

import Foundation

/// - Parameters
///   - id: identifier
///   - name: Contact name
///   - iconURL: URL of the contact icon/avatar
struct Chat: Identifiable, Codable {
    var id: String {
        self.name
    }
    var name: String
    var iconURL: String
}
