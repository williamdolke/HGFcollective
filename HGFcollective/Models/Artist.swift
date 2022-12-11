//
//  Artist.swift
//  HGF Collective
//
//  Created by William Dolke on 13/09/2022.
//

import Foundation

/// - Parameters
///   - id: identifier
///   - name: Name of the artist
///   - biography: A biography of the artist
///   - artworks: An array of the artist's artworks
struct Artist: Identifiable, Codable {
    var id: String {
            self.name
        }
    var name: String
    var biography: String
    // An artist may not have any artworks in the database or they may not have been fetched yet
    var artworks: [Artwork]?
}
