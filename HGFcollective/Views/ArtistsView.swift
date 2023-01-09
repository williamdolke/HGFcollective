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
    @State private var segmentationSelection : ProfileSection = .grid

    // Define the segmented control segments
    enum ProfileSection : String, CaseIterable {
        case grid = "Grid"
        case list = "List"
    }

    var body: some View {
        NavigationStack {
            segmentedControl
                .padding()
            chosenSegmentView()
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
        }
    }

    /// Create the segmented picker from the enum cases
    private var segmentedControl: some View {
        Picker("", selection: $segmentationSelection) {
            ForEach(ProfileSection.allCases, id: \.self) { option in
                Text(option.rawValue)
            }
        }.pickerStyle(SegmentedPickerStyle())
    }

    /// Define the view presented for each segment
    @ViewBuilder
    private func chosenSegmentView() -> some View {
        switch segmentationSelection {
        case .grid:
            artistsGrid
        case .list:
            artistsList
        }
    }

    /// Display the filtered artists in a grid with two columns that extend vertically
    @ViewBuilder
    private var artistsGrid: some View {
        let columns = [GridItem(), GridItem()]
        // The GeometryReader needs to be defined outside the ScrollView, otherwise it won't
        // take the dimensions of the screen
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns) {
                    // Create an ImageBubble for each artist that meets the filter criteria
                    ForEach(filteredArtists) { artist in
                        let artwork = (artist.artworks?.isEmpty == false) ? artist.artworks![0] : Artwork(name: "")
                        NavigationLink(destination: ArtistView(artist: artist)) {
                            ImageBubble(assetName: artwork.name + " 1",
                                        height: nil,
                                        width: 0.45 * geo.size.width,
                                        fill: true)
                            .background(Color.theme.accent)
                            .cornerRadius(0.1 * min(geo.size.height, geo.size.width))
                        }
                    }
                }
            }
        }
    }

    /// Display the filtered artists in a list
    private var artistsList: some View {
        Form {
            Section {
                // Add a navigationLink for every artist that meets the filter criteria
                ForEach(filteredArtists) { artist in
                    NavigationLink(artist.name, destination: ArtistView(artist: artist))
                }
            }
        }
    }

    /// Filter the artists displayed by comparing text entered into the search bar to the artist names
    var filteredArtists: [Artist] {
        // Array of artists that meet the filter criteria
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
