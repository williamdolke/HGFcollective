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

    private var discoverPictures: some View {
        // The GeometryReader needs to be defined outside the ScrollView, otherwise it won't
        // take the dimensions of the screen
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0.03 * geo.size.width) {
                    ForEach(0..<artistManager.numDiscoverArtists, id: \.self) {index in
                        let artistIndex = artistManager.discoverArtistIndexes![index]
                        let artistArtwork = artistManager.artists[artistIndex].artworks
                        let artworkAssetName = (artistArtwork?.isEmpty == false) ? artistArtwork![0].name : ""
                        let artworkURL = (artistArtwork?.isEmpty == false) ? artistArtwork![0].urls?[0] : nil

                        NavigationLink(destination: ArtistView(artist: artistManager.artists[artistIndex])) {
                            ImageBubble(assetName: artworkAssetName + " 1",
                                        url: artworkURL,
                                        height: geo.size.height,
                                        width: 0.45 * geo.size.width,
                                        fill: true)
                            .background(Color.theme.accent)
                            .cornerRadius(0.2 * min(geo.size.height, geo.size.width))
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var featuredPictures: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0.03 * geo.size.width) {
                    let featuredArtist = artistManager.artists[artistManager.featuredArtistIndex!]
                    ForEach(0..<(featuredArtist.artworks?.count ?? 0),
                            id: \.self) {index in
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
