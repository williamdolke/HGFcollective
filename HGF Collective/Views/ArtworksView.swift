//
//  ArtworksView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI

struct ArtworksView: View {
    @EnvironmentObject var artistManager: ArtistManager
    @State var searchQuery = ""

    var body: some View {
        ZStack {
            NavigationView {
                Form {
                    ForEach(filteredArtists.0) { filteredArtist in
                        Section {
                            ForEach(filteredArtist.artworks!) { artwork in
                                if filteredArtists.1.contains(artwork.name) {
                                    NavigationLink(artwork.name, destination: ArtworkView(artwork: artwork))
                                }
                            }
                        } header: {
                            Text(filteredArtist.name)
                        }
                    }
                }
                .navigationTitle("Artworks")
                .searchable(text: $searchQuery, prompt: "Search By Artwork Name")
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
    }

    var filteredArtists: ([Artist], [String]) {
        var filteredArtists: [Artist] = []
        var filteredArtworks: [String] = []
        var alreadyFiltered: Bool = false

        artistManager.artists.forEach { artist in
            alreadyFiltered = false
            artist.artworks?.forEach {artwork in
                if artwork.name.localizedCaseInsensitiveContains(searchQuery) || searchQuery == "" {
                    filteredArtworks.append(artwork.name)
                    if !alreadyFiltered {
                        filteredArtists.append(artist)
                        alreadyFiltered = true
                    }
                }
            }
        }
        return (filteredArtists, filteredArtworks)
    }
}

struct ArtworksView_Previews: PreviewProvider {
    static let artistManager = ArtistManager()

    static var previews: some View {
        ArtworksView()
            .environmentObject(artistManager)

        ArtworksView()
            .environmentObject(artistManager)
            .preferredColorScheme(.dark)
    }
}
