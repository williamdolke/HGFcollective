//
//  User.swift
//  HGF Collective
//
//  Created by William Dolke on 26/09/2022.
//

import Foundation

/// - Parameters
///   - id: identifier
///   - messagePreview: Preview of the most recent chat
///   - latestTimestamp: The time that the latest message was sent
///   - read: Has the user receiving the message read the message
///   - sender: The UUID of the user who sent the most recent message
struct User: Identifiable, Codable {
    var id: String
    var messagePreview: String
    var latestTimestamp: Date
    var read: Bool
    var sender: String
}
