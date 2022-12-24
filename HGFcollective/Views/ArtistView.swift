//
//  ArtistView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI

struct ArtistView: View {
    var artist: Artist

    // Store images to be shown in the snap carousel
    @State private var images: [Asset] = []
    // Store the current image in the snap carousel
    @State private var currentIndex: Int = 0

    var body: some View {
        VStack {
            artworkImages
            imageIndexIndicator
            biography
        }
        .navigationBarTitle(artist.name, displayMode: .inline)
        .onAppear {
            for index in 1...10 {
                let artistArtworks = artist.artworks
                let artworkAssetName = (artistArtworks!.count >= index) ? (artistArtworks![index-1].name + " 1") : ""
                let image = Asset(assetName: artworkAssetName)
                if (UIImage(named: artworkAssetName) != nil && !images.contains { $0.assetName == image.assetName }) {
                    images.append(image)
                }
            }
        }
    }

    /// Display all images of the artwork in a snap carousel
    var artworkImages: some View {
        GeometryReader { geo in
            SnapCarousel(index: $currentIndex, items: images) { image in
                NavigationLink(destination: ArtworkView(artwork: (artist.artworks?[currentIndex])!)) {
                    ImageBubble(assetName: image.assetName,
                                height: geo.size.height,
                                width: geo.size.width * 0.9)
                    .frame(width: geo.size.width, height: geo.size.height)
                    // Repeat to center the image
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            }
        }
    }

    /// Indicate which image number is being displayed by the snap carousel
    private var imageIndexIndicator: some View {
        HStack(spacing: 10) {
            ForEach(images.indices, id: \.self) { index in
                Circle()
                    .fill(Color.theme.accentSecondary.opacity(currentIndex == index ? 1 : 0.1))
                    .frame(width: 8, height: 8)
                    .scaleEffect(currentIndex == index ? 1.4 : 1)
                    .animation(.spring(), value: currentIndex == index)
            }
        }
    }

    /// Display the artist's biography
    private var biography: some View {
        ScrollView {
            Text(artist.biography)
                .padding()
                .background(.ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius: 20, style: .continuous))
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
