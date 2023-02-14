//
//  HomeView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI
import FirebaseAnalytics

struct HomeView: View {
    @EnvironmentObject var artistManager: ArtistManager

    @State private var showMenu = false

    var body: some View {
        NavigationStack {
            VStack {
                titleRow

                Text("Discover")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                discoverPictures

                Text("Featured Artist - \(artistManager.featuredArtistName ?? "")")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                featuredPictures
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("IconCircle")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
            }
            .sheet(isPresented: $showMenu) {
                MenuView()
                    .accentColor(Color.theme.navigationBarAccent)
            }
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "\(HomeView.self)",
                                               AnalyticsParameterScreenClass: "\(HomeView.self)"])
            }
        }
    }

    private var titleRow: some View {
        HStack {
            Text("Home")
                .font(.largeTitle.bold())
                .padding(.horizontal)
            Spacer()
            Button {
                showMenu.toggle()
                logger.info("User tapped the menu button")
            } label: {
                Image(systemName: "line.3.horizontal")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .padding()
            }
        }
        .foregroundColor(Color.theme.navigationBarAccent)
        .background(Color.theme.accent)
    }

    /// Every time the app is launched a selection of randomly selected
    /// artists have an artwork displayed in a "discover" section
    private var discoverPictures: some View {
        // The GeometryReader needs to be defined outside the ScrollView, otherwise it won't
        // take the dimensions of the screen
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0.03 * geo.size.width) {
                    // Select a number of artists to be in the "discover" section, as defined by numDiscoverArtists
                    ForEach(0..<artistManager.numDiscoverArtists, id: \.self) { index in
                        let artistIndex = artistManager.discoverArtistIndexes![index]
                        let artistArtworks = artistManager.artists[artistIndex].artworks
                        let noArtworks = artistArtworks?.isEmpty

                        // If the artist has no artworks then the artworkAssetName will be an empty string,
                        // and no artwork image will be found. Additionally, artworkURL will be nil and hence
                        // the default image will be displayed.
                        let artworkAssetName = (noArtworks == false) ? artistArtworks![0].name : ""
                        let artworkURL = (noArtworks == false) ? artistArtworks![0].urls?[0] : nil

                        // Display the first image of the first artwork by the current artist.
                        // When the image is tapped a view will be presented with information about
                        // the artist as well as the first image of each artwork by the artist.
                        NavigationLink(destination: ArtistView(artist: artistManager.artists[artistIndex])) {
                            ImageBubble(assetName: artworkAssetName + " 1",
                                        url: artworkURL,
                                        height: geo.size.height,
                                        width: 0.45 * geo.size.width,
                                        fill: true)
                            .background(Color.theme.accent)
                            // Take the minimum so that corners radius doesn't get
                            // very large if the bubble is very tall or very wide
                            .cornerRadius(0.2 * min(geo.size.height, geo.size.width))
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    /// Every time the app is launched a "featured artists" is chosen.
    /// This artist will have their artworks displayed on the home screen.
    private var featuredPictures: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0.03 * geo.size.width) {
                    let featuredArtist = artistManager.artists[artistManager.featuredArtistIndex!]
                    // Display the first image of each artwork by the featured artist.
                    // When the image is tapped a view will be presented with information about
                    // the artwork as well as the rest of the images of the artwork.
                    ForEach(0..<(featuredArtist.artworks?.count ?? 0), id: \.self) { index in
                        let artwork = featuredArtist.artworks![index]
                        NavigationLink(destination: ArtworkView(artwork: artwork)) {
                            ImageBubble(assetName: artwork.name + " 1",
                                        url: artwork.urls?[0],
                                        height: geo.size.height,
                                        width: 0.9 * geo.size.width,
                                        fill: true)
                            .background(Color.theme.accent)
                            // Take the minimum so that corners radius doesn't get
                            // very large if the bubble is very tall or very wide
                            .cornerRadius(0.2 * min(geo.size.height, geo.size.width))
                        }
                    }
                }
            }
        }
        .padding([.horizontal, .bottom])
    }
}

struct HomeView_Previews: PreviewProvider {
    static let artistManager = ArtistManager()

    static var previews: some View {
        HomeView()
            .environmentObject(artistManager)

        HomeView()
            .environmentObject(artistManager)
            .preferredColorScheme(.dark)
    }
}
