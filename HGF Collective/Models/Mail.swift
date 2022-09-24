//
//  Mail.swift
//  HGF Collective
//
//  Created by William Dolke on 16/09/2022.
//

import Foundation

struct Mail: Identifiable, Codable {
    var id: String {
        self.recipients[0]
    }
    var recipients: [String]
    var subject: String?
    var msgBody: String?
}
