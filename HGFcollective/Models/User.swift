//
//  User.swift
//  HGF Collective
//
//  Created by William Dolke on 26/09/2022.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String
    var messagePreview: String
    var latestTimestamp: Date
}
