//
//  ImageBubbleWide.swift
//  HGF Collective
//
//  Created by William Dolke on 18/09/2022.
//

import SwiftUI

struct ImageBubbleWide: View {
    let artwork: Artwork

    var body: some View {
        HStack {
            let artworkAssetName = artwork.name + " 1"

            if (artwork.url != nil) {
                AsyncImage(url: URL(string: artwork.url!)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 400, height: 300)
                        .frame(width: 400, height: 300)
                } placeholder: {
                    ProgressView()
                }
            } else if (UIImage(named: artworkAssetName) != nil) {
                Image(artworkAssetName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 400, height: 300)
                    .frame(width: 400, height: 300)
            } else {
                Image(systemName: "photo.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 400, height: 300)
                    .frame(width: 400, height: 300)
            }
        }
    }
}

struct ImageBubbleWide_Previews: PreviewProvider {
    static var previews: some View {
        ImageBubble(artwork: Artwork(name: "Artwork"), height: 300, width: 400)
    }
}
