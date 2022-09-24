//
//  Artist.swift
//  HGF Collective
//
//  Created by William Dolke on 13/09/2022.
//

import Foundation

struct Artist: Identifiable, Codable {
    var id: String {
            self.name
        }
    var name: String
    var biography: String
    var artworks: [Artwork]?
    var match: Bool?
}
