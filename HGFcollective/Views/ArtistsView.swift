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
                } header: {
                    // Empty section label to add spacing
                    Text("")
                }
            }
            .navigationTitle("Artists")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("IconCircle")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
            }
            .searchable(text: $searchQuery, prompt: "Search By Artist Name")

            // The secondary view that will be shown on devices with a sidebar
            ArtistView(artist: artistManager.artists[0])
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
