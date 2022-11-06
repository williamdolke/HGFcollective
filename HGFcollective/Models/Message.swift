//
//  Message.swift
//  HGF Collective
//
//  Created by William Dolke on 12/09/2022.
//

import Foundation

struct Message: Identifiable, Codable {
    var id: String
    var content: String
    var isCustomer: Bool
    var timestamp: Date
    var type: String
}
