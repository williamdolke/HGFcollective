//
//  ArtistView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI

struct ArtistView: View {
    var artist: Artist

    var body: some View {
        VStack {
            artworkImages

            ScrollView {
                Text(artist.biography)
                    .padding()
                    .background(.ultraThinMaterial,
                                in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .padding()
        }
        .navigationBarTitle(artist.name, displayMode: .inline)
    }

    var artworkImages: some View {
        GeometryReader { geo in
            ScrollView(.horizontal) {
                HStack {
                    ForEach((0...9), id: \.self) {
                        let artistArtworks = artist.artworks
                        let artworkAssetName = (artistArtworks!.count-1 >= $0) ? (artistArtworks![$0].name + " 1") : ""

                        if (UIImage(named: artworkAssetName) != nil) {
                            NavigationLink(destination: ArtworkView(artwork: (artist.artworks?[$0])!)) {
                                ImageBubble(assetName: artworkAssetName,
                                            height: geo.size.height,
                                            width: geo.size.width * 0.9)
                                .frame(width: geo.size.width, height: geo.size.height)
                                // Repeat to center the image
                                .frame(width: geo.size.width, height: geo.size.height)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ArtistView_Previews: PreviewProvider {
    static let artist = Artist(name: "Artist",
                        biography: """
                        I am an artist that likes to paint with oil paints.
                        My favourite thing to paint is the sea!
                        """,
                        artworks: [Artwork(name: "Mr monopoly man"),
                                   Artwork(name: "Mr monopoly man vinyl and opening night memorabilia")])

    static var previews: some View {
        ArtistView(artist: artist)

        ArtistView(artist: artist)
            .preferredColorScheme(.dark)
    }
}
