//
//  ImageBubbleTall.swift
//  HGF Collective
//
//  Created by William Dolke on 18/09/2022.
//

import SwiftUI

struct ImageBubbleTall: View {
    let artwork: Artwork

    var body: some View {
        HStack {
            let artworkAssetName = artwork.name + " 1"

            if (artwork.url != nil) {
                AsyncImage(url: URL(string: artwork.url!)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 300, height: 400)
                        .frame(width: 300, height: 400)
                } placeholder: {
                    ProgressView()
                }
            } else if (UIImage(named: artworkAssetName) != nil) {
                Image(artworkAssetName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 400)
                    .frame(width: 300, height: 400)
            } else {
                Image(systemName: "person.crop.artframe")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 400)
                    .frame(width: 300, height: 400)
            }
        }
    }
}

struct ImageBubble_Previews: PreviewProvider {
    static var previews: some View {
        ImageBubbleTall(artwork: Artwork(name: "Artwork"))
    }
}
