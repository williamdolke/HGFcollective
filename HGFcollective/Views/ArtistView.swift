//
//  ArtistView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI
import FirebaseAnalytics

struct ArtistView: View {
    var artist: Artist

    // Store images to be shown in the snap carousel
    @State private var images: [Asset] = []
    // Store the current image in the snap carousel
    @State private var currentIndex: Int = 0

    var body: some View {
        // The GeometryReader needs to be defined outside the ScrollView, otherwise it won't
        // take the dimensions of the screen
        GeometryReader { geo in
            ScrollView {
                VStack {
                    SnapCarousel(index: $currentIndex, items: images) { image in
                        let haveURL = image.url != ""
                        NavigationLink(destination: ArtworkView(artwork: (artist.artworks?[image.index])!)) {
                            ImageBubble(assetName: image.assetName,
                                        url: haveURL ? image.url : nil,
                                        height: 0.6 * geo.size.height,
                                        width: nil)
                        }
                    }
                    _VSpacer(minHeight: 0.6 * geo.size.height)

                    imageIndexIndicator
                    biography
                        .padding(.horizontal)
                }
            }
        }
        .navigationBarTitle(artist.name, displayMode: .inline)
        .onAppear {
            // Check which artworks have a primary/first image to display
            for index in 1...10 {
                let artistArtworks = artist.artworks
                let artworkAssetName = (artistArtworks!.count >= index) ? (artistArtworks![index-1].name + " 1") : ""
                let urls = (artistArtworks!.count >= index) ? artistArtworks![index-1].urls : nil
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

            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "\(ArtistView.self)",
                                           AnalyticsParameterScreenClass: "\(ArtistView.self)"])
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
        Text(artist.biography)
            .padding()
            .background(.ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous))
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
