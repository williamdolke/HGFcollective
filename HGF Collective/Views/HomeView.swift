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
                    GeometryReader { geo in
                        ScrollView(.horizontal) {
                            HStack(spacing: geo.size.width * 0.04) {
                                ForEach(0..<artistManager.numDiscoverArtworks, id: \.self) {index in
                                    NavigationLink(destination: ArtistView(artist: artistManager.artists[2*index+1])) {
                                        ImageBubbleTall()
                                            .frame(width: geo.size.width * 0.48, height: geo.size.height)
                                            .cornerRadius(geo.size.width * 0.3)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    Text("Featured Artist - \(artistManager.featuredArtistName ?? "")")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    GeometryReader { geo in
                        ScrollView(.horizontal) {
                            HStack(spacing: geo.size.width * 0.04) {
                                ForEach(0..<(artistManager.artists[artistManager.featuredArtistIndex!].artworks?.count ?? 0), id: \.self) {index in
                                    NavigationLink(destination: ArtworkView(artwork: artistManager.artists[artistManager.featuredArtistIndex!].artworks![index])) {
                                        ImageBubbleWide()
                                            .frame(width: geo.size.width, height: geo.size.height)
                                            .cornerRadius(geo.size.width * 0.15)
                                    }
                                }
                            }
                        }
                    }
                    .padding([.horizontal, .bottom])

                    Spacer()

                }
                .navigationTitle("Home")
                .navigationBarItems(trailing:
                                        Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .padding(.top, 90))
            }
        }
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
