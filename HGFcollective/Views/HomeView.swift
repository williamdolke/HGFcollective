//
//  HomeView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI

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
                    .padding()
                discoverPictures

                Text("Featured Artist - \(artistManager.featuredArtistName ?? "")")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                featuredPictures
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image("IconCircle")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
            }
            .sheet(isPresented: $showMenu) {
                MenuView()
            }
        }
    }

    private var titleRow: some View {
        HStack {
            Text("Home")
                .font(.largeTitle.bold())
                .padding()
            Spacer()
            Button {
                showMenu.toggle()
            } label: {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .padding()
            }
        }
    }

    private var discoverPictures: some View {
        GeometryReader { geo in
            ScrollView(.horizontal) {
                HStack(spacing: 0.03 * geo.size.width) {
                    ForEach(0..<artistManager.numDiscoverArtists, id: \.self) {index in
                        let artistIndex = artistManager.discoverArtistIndexes![index]
                        let artistArtwork = artistManager.artists[artistIndex].artworks
                        let artworkAssetName = (artistArtwork?.isEmpty == false) ? artistArtwork![0].name : ""

                        NavigationLink(destination: ArtistView(artist: artistManager.artists[artistIndex])) {
                            ImageBubble(assetName: artworkAssetName + " 1",
                                        height: geo.size.height,
                                        width: geo.size.width * 0.45,
                                        fill: true)
                            .background(Color.theme.bubble)
                            .cornerRadius(geo.size.width * 0.15)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var featuredPictures: some View {
        GeometryReader { geo in
            ScrollView(.horizontal) {
                HStack(spacing: 0.03 * geo.size.width) {
                    let featuredArtist = artistManager.artists[artistManager.featuredArtistIndex!]
                    ForEach(0..<(featuredArtist.artworks?.count ?? 0),
                            id: \.self) {index in
                        let artwork = featuredArtist.artworks![index]
                        NavigationLink(destination: ArtworkView(artwork: artwork)) {
                            ImageBubble(assetName: artwork.name + " 1",
                                        height: geo.size.height,
                                        width: 0.9 * geo.size.width,
                                        fill: true)
                                .background(Color.theme.bubble)
                                .cornerRadius(geo.size.width * 0.15)
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
