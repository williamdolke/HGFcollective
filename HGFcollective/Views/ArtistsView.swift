//
//  ArtistsView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI

struct ArtistsView: View {
    @EnvironmentObject var artistManager: ArtistManager

    @State private var searchQuery = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    ForEach(filteredArtists) { artist in
                        NavigationLink(artist.name, destination: ArtistView(artist: artist))
                    }
                }
            }
            .navigationTitle("Artists")
            .searchable(text: $searchQuery, prompt: "Search By Artist Name")
        }
    }

    var filteredArtists: [Artist] {
        var filteredArtists: [Artist] = []
        artistManager.artists.forEach { artist in
            if artist.name.localizedCaseInsensitiveContains(searchQuery) || searchQuery == "" {
                filteredArtists.append(artist)
            }
        }
        return filteredArtists
    }
}

struct ArtistsView_Previews: PreviewProvider {
    static let artistManager = ArtistManager()

    static var previews: some View {
        ArtistsView()
            .environmentObject(artistManager)

        ArtistsView()
            .environmentObject(artistManager)
            .preferredColorScheme(.dark)
    }
}
