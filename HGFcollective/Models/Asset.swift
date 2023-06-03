//
//  Asset.swift
//  HGFcollective
//
//  Created by William Dolke on 13/12/2022.
//

import SwiftUI

/// - Parameters
///   - id: identifier
///   - assetName: Name of the image in Assets.xcassets
///   - index: Index of the image
///   - url: URL of the image
struct Asset: Identifiable {
    var id = UUID().uuidString
    var assetName: String
    var index: Int
    var url: String?
}
