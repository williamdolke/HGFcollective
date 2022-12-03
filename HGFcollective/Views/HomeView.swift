//
//  HomeView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var artistManager: ArtistManager

    var body: some View {
        VStack {
            NavigationView {
                VStack {
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

                    Spacer()

                }
                .navigationTitle("Home")
                .navigationBarItems(trailing: Image("HGF Circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .padding(.top, 90))
            }
        }
    }

    private var discoverPictures: some View {
        GeometryReader { geo in
            ScrollView(.horizontal) {
                HStack(spacing: geo.size.width * 0.04) {
                    ForEach(0..<artistManager.numDiscoverArtworks, id: \.self) {index in
                        NavigationLink(destination: ArtistView(artist: artistManager.artists[2*index+1])) {
                            ImageBubble(assetName: "Artwork 1",
                                        height: geo.size.height,
                                        width: geo.size.width * 0.48)
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
                HStack(spacing: geo.size.width * 0.04) {
                    let featuredArtist = artistManager.artists[artistManager.featuredArtistIndex!]
                    ForEach(0..<(featuredArtist.artworks?.count ?? 0),
                            id: \.self) {index in
                        let artwork = featuredArtist.artworks![index]
                        NavigationLink(destination: ArtworkView(artwork: artwork)) {
                            ImageBubble(assetName: artwork.name + " 1",
                                        height:geo.size.height,
                                        width:geo.size.width)
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
    static var artistManager = ArtistManager()

    static var previews: some View {
        HomeView()
            .environmentObject(artistManager)

        HomeView()
            .environmentObject(artistManager)
            .preferredColorScheme(.dark)
    }
}
