//
//  Chat.swift
//  HGF Collective
//
//  Created by William Dolke on 17/09/2022.
//

import Foundation

struct Chat: Identifiable, Codable {
    var id: String {
        self.name
    }
    var name: String
    var iconURL: String
}
