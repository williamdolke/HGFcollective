//
//  Message.swift
//  HGF Collective
//
//  Created by William Dolke on 12/09/2022.
//

import Foundation

/// - Parameters
///   - id: identifier
///   - content: The message text or URL of the image in storage
///   - isCustomer: True if the message was sent by the customer. False if the message was sent by the admin(s).
///   - timestamp: The time that the message was sent
///   - type: "image" or "text"
struct Message: Identifiable, Codable {
    var id: String
    var content: String
    var isCustomer: Bool
    var timestamp: Date
    var type: String
}
