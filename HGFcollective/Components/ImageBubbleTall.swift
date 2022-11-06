//
//  ImageBubbleTall.swift
//  HGF Collective
//
//  Created by William Dolke on 18/09/2022.
//

import SwiftUI

struct ImageBubbleTall: View {
    let artwork: Artwork
    var imageURL = "https://d7hftxdivxxvm.cloudfront.net/?resize_to=fit&width=800&height=800&quality=80&src=https%3A%2F%2Fd32dm0rphc51dk.cloudfront.net%2Fp0hK-VVvk0WQVXlfweVzLw%2Fnormalized.jpg"

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
