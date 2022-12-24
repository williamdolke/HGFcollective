//
//  ImageBubble.swift
//  HGF Collective
//
//  Created by William Dolke on 18/09/2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageBubble: View {
    let assetName: String
    var url: String?
    // Optionally specify the height and/or width of the bubble
    let height: CGFloat?
    let width: CGFloat?
    // Optionally whether the image should fill the bubble.
    // Defaults to .fit if unspecified/false.
    var fill: Bool = false

    var body: some View {
        HStack {
            if (url != nil) {
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
                Image(assetName)
                    .resizable()
                    .aspectRatio(contentMode: fill ? .fill : .fit)
                    .frame(width: width, height: height)
            } else {
                // Show a SF symbol as a last resort
                Image(systemName: "photo.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
            }
        }
    }
}

struct ImageBubble_Previews: PreviewProvider {
    static var previews: some View {
        ImageBubble(assetName: "Artwork 1",
                    height: 400,
                    width: 300)
    }
}
