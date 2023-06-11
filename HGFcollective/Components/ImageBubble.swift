//
//  ImageBubble.swift
//  HGF Collective
//
//  Created by William Dolke on 18/09/2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageBubble: View {
    // Artwork images in Assets.xcassets will follow the naming convention "<artworkName> 1"
    // and the integer number will increment as more images are added
    let assetName: String
    var url: String?
    // Optionally specify the height and/or width of the bubble
    let height: CGFloat?
    let width: CGFloat?
    // Optionally specify whether the image should fill the bubble.
    // Defaults to .fit if unspecified/false.
    var fill: Bool = false

    var body: some View {
        HStack {
            if (url != nil && url != "") {
                // Prioritise displaying images via url. This allows us to update
                // images that are built in to the app (such as artworks) by providing
                // an image url in the database
                WebImage(url: URL(string: url!))
                    .resizable()
                    .placeholder {
                        ProgressView()
                    }
                    .aspectRatio(contentMode: fill ? .fill : .fit)
                    .frame(width: width, height: height)
            } else if (UIImage(named: assetName) != nil) {
                // Try to find the image in Assets.xcassets
                // Convert a UIImage() to Image() to allow cached images to
                // be freed from memory when the amount available is low
// https://www.hackingwithswift.com/forums/swiftui/how-can-i-get-swiftui-to-release-cached-image-memory/9862
                Image(uiImage: UIImage(named: assetName)!)
                    .resizable()
                    .aspectRatio(contentMode: fill ? .fill : .fit)
                    .frame(width: width, height: height)
            } else {
                // Show a SF symbol as a last resort
                Image(systemName: "photo.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
                    .background(Color.theme.accent)
                    .foregroundColor(Color.theme.navigationBarAccent)
            }
        }
    }
}

struct ImageBubble_Previews: PreviewProvider {
    static var previews: some View {
        ImageBubble(assetName: "Artwork 1",
                    height: 400,
                    width: 300)

        ImageBubble(assetName: "Artwork 1",
                    height: 400,
                    width: 300)
        .preferredColorScheme(.dark)
    }
}
