//
//  Asset.swift
//  HGFcollective
//
//  Created by William Dolke on 13/12/2022.
//

import SwiftUI

/// - Parameters
///   - id: identifier
///   - assetName: Name fo the image in Assets.xcassets
struct Asset: Identifiable {
    var id = UUID().uuidString
    var assetName: String
    var url: String?
    var index: Int?
}
