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
///   - changed: Whether there is a pending operation to be performed on the Asset
struct Asset: Identifiable, Equatable {
    var id = UUID().uuidString
    var assetName: String
    var index: Int
    var url: String?
    var uiImage: UIImage?
    var changed: Bool?
}
