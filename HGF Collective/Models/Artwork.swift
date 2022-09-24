//
//  Artwork.swift
//  HGF Collective
//
//  Created by William Dolke on 15/09/2022.
//

import Foundation

struct Artwork: Identifiable, Codable {
    var id: String {
            self.name
        }
    var name: String
    var url: String?
    var editionNumber: String?
    var editionSize: String?
    var material: String?
    var dimensionUnframed: String?
    var dimensionFramed: String?
    var year: String?
    var signed: String?
    var numbered: String?
    var stamped: String?
    var authenticity: String?
}
