//
//  ImageUtils.swift
//  HGFcollective
//
//  Created by William Dolke on 20/12/2023.
//

import Foundation
import UIKit

struct ImageUtils {
    /// Check for images of an artwork to display. 
    /// Returns a tuple with an array of images and the number of images from Assets.xcassets;
    static func getImages(artworkName: String, artworkURLs: [String]?) -> (images: [Asset], numAssets: Int?) {
        var images: [Asset] = []
        var numAssets = 0
        for index in 1...Constants.maximumImages {
            let artworkAssetName = artworkName + " " + String(index)
            // url is an empty string if the artwork image hasn't been overriden from the database
            let url = (artworkURLs?.count ?? 0 >= index) ? artworkURLs?[index-1] : ""

            // Append the image if we have a url or it is found in
            // Assets.xcassets and isn't already in the array
            let haveURL = (url != "")
            let haveAsset = artworkAssetName != "" &&
            UIImage(named: artworkAssetName) != nil
            let image = Asset(assetName: artworkAssetName,
                              index: index,
                              url: url)
            if ((haveURL || haveAsset) &&
                !images.contains { $0.assetName == image.assetName }) {
                images.append(image)
            }
            if haveAsset {
                numAssets += 1
            }
        }
        return (images, (numAssets != 0) ? numAssets : nil)
    }

    /// Check for only the first image for a series of artworks and return them in the form of an Asset
    static func getFirstImageForEachArtwork(artworks: [Artwork]) -> [Asset] {
        var images: [Asset] = []
        for index in 1...Constants.maximumImages {
            let artworkAssetName = (artworks.count >= index) ? (artworks[index-1].name + " 1") : ""
            let urls = (artworks.count >= index) ? artworks[index-1].urls : nil
            // The URL is an empty string if the first artwork image hasn't been overriden from the database
            let url = (urls?.count ?? 0 > 0) ? urls?[0] : ""
            // We need to store the index so we know which will be displayed and which have been skipped
            let image = Asset(assetName: artworkAssetName, index: index-1, url: url)

            // Append the image if we have a url or it is found in
            // Assets.xcassets and isn't already included in the array
            let haveURL = (url != "")
            let haveAsset = artworkAssetName != "" &&
            UIImage(named: artworkAssetName) != nil
            if ((haveURL || haveAsset) &&
                !images.contains { $0.assetName == image.assetName }) {
                images.append(image)
            }
        }
        return images
    }
}
