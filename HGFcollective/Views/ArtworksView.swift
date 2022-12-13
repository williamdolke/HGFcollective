//
//  ArtworksView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI

struct ArtworksView: View {
    @EnvironmentObject var artistManager: ArtistManager
    @EnvironmentObject var favourites: Favourites

    @State private var searchQuery = ""

    var body: some View {
        NavigationView {
            Form {
                artistSections
            }
            .navigationTitle("Artworks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image("IconCircle")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
            }
            .searchable(text: $searchQuery, prompt: "Search By Artwork Name")
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        }
    }

    private var artistSections: some View {
        ForEach(filteredArtists.0) { filteredArtist in
            Section {
                ForEach(filteredArtist.artworks!) { artwork in
                    if filteredArtists.1.contains(artwork.name) {
                        NavigationLink {
                            ArtworkView(artwork: artwork)
                        } label: {
                            artworkLabel(artworkName: artwork.name)
                        }
                    }
                }
            } header: {
                Text(filteredArtist.name)
            }
        }
    }

    private func artworkLabel(artworkName: String) -> some View {
        HStack {
            Text(artworkName)

            if favourites.contains(artworkName) {
                Spacer()
                Image(systemName: "heart.fill")
                    .accessibilityLabel("This is a favourite artwork")
                    .foregroundColor(Color.theme.favourite)
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
    static let favourites = Favourites()

    static var previews: some View {
        ArtworksView()
            .environmentObject(artistManager)
            .environmentObject(favourites)

        ArtworksView()
            .environmentObject(artistManager)
            .environmentObject(favourites)
            .preferredColorScheme(.dark)
    }
}
