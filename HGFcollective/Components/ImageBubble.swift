//
//  ImageBubble.swift
//  HGF Collective
//
//  Created by William Dolke on 18/09/2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageBubble: View {
    let artwork: Artwork
    let height: CGFloat
    let width: CGFloat

    var body: some View {
        HStack {
            let artworkAssetName = artwork.name + " 1"

            if (artwork.url != nil) {
                WebImage(url: URL(string: artwork.url!))
                    .resizable()
                    .placeholder {
                        ProgressView()
                    }
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height)
            } else if (UIImage(named: artworkAssetName) != nil) {
                Image(artworkAssetName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height)
            } else {
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
        ImageBubble(artwork: Artwork(name: "Artwork"), height: 400, width: 300)
    }
}
