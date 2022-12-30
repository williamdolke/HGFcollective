//
//  Artwork.swift
//  HGF Collective
//
//  Created by William Dolke on 15/09/2022.
//

import Foundation

/// - Parameters
///   - id: identifier
///   - name: Name of the artwork
///   - url: URL of the image of the artwork
///   - editionNumber: Edition number
///   - editionSize: Number of pieces produced in  the edition
///   - material: Materials used to produce the artwork
///   - dimensionUnframed: Unframed dimensions
///   - dimensionFramed: Framed dimensions
///   - year: Year of creation
///   - signed: "Yes" if the artwork is signed, "No" otherwise
///   - numbered: "Yes" if the artwork is numbered, "No" otherwise
///   - stamped: "Yes" if the artwork is stamped, "No" otherwise
///   - authenticity: "Yes" if there is proof of authenticity, "No" otherwise
///   - price: Price
struct Artwork: Identifiable, Codable {
    var id: String {
            self.name
        }
    var name: String
    // The following properties may not be provided in the database. Only
    // those that are successfully fetched will be presented in the
    // ArtworkView UI.

    // urls is an array to allow for individual artwork images to be overriden from the database
    var urls: [String]?
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
    var price: String?
}
