//
//  Mail.swift
//  HGF Collective
//
//  Created by William Dolke on 16/09/2022.
//

import Foundation

/// - Parameters
///   - id: identifier
///   - recipients: An array of email addesses that the email will be sent to
///   - subject: The subject of the email
///   - msgBody: The body of the email
struct Mail: Identifiable, Codable {
    var id: String {
        // Just choose the first element as this should always exist
        self.recipients[0]
    }
    var recipients: [String]
    var subject: String?
    var msgBody: String?
}
