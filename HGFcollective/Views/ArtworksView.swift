//
//  ArtworksView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI
import FirebaseAnalytics

struct ArtworksView: View {
    @EnvironmentObject var artistManager: ArtistManager
    @EnvironmentObject var favourites: Favourites

    @State private var searchQuery = ""
    @State private var segmentationSelection : ProfileSection = .grid
    private var height = UIScreen.main.bounds.size.height
    private var width = UIScreen.main.bounds.size.width

    // Define the segmented control segments
    enum ProfileSection : String, CaseIterable {
        case grid = "Grid"
        case list = "List"
        case favourites = "Favourites"
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                segmentedControl
                    .padding()
                chosenSegmentView()
            }
            .navigationTitle("Artworks")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("IconCircle")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
            }
            .searchable(text: $searchQuery, prompt: "Search By Artwork Name")
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "\(ArtworksView.self)",
                                               AnalyticsParameterScreenClass: "\(ArtworksView.self)"])
            }
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
            artworksGrid
        case .list:
            artworksList
        case .favourites:
            favouritesGrid
        }
    }

    /// Display the filtered artworks in a grid with two columns that extend vertically
    @ViewBuilder
    private var artworksGrid: some View {
        let columns = [GridItem(), GridItem()]
        LazyVGrid(columns: columns) {
            // Create an ImageBubble for each artwork that meets the filter criteria
            ForEach(filteredArtists.0) { artist in
                ForEach(artist.artworks!) { artwork in
                    if filteredArtists.1.contains(artwork.name) {
                        NavigationLink(destination: ArtworkView(artwork: artwork)) {
                            ImageBubble(assetName: artwork.name + " 1",
                                        height: nil,
                                        width: 0.45 * width,
                                        fill: true)
                            .background(Color.theme.accent)
                            .cornerRadius(0.1 * min(height, width))
                        }
                    }
                }
            }
        }
    }

    /// Display the filtered artworks in a list organised into sections by artist
    private var artworksList: some View {
        Form {
            // Create a section for every artist who has an artwork that
            // meets the filter criteria
            ForEach(filteredArtists.0) { filteredArtist in
                Section {
                    // Add a navigationLink for every artwork by the artist
                    // that meets the filter criteria
                    ForEach(filteredArtist.artworks!) { filteredArtwork in
                        if filteredArtists.1.contains(filteredArtwork.name) {
                            NavigationLink {
                                ArtworkView(artwork: filteredArtwork)
                            } label: {
                                artworkLabel(artworkName: filteredArtwork.name)
                            }
                        }
                    }
                } header: {
                    // Section label
                    Text(filteredArtist.name)
                }
            }
        }
    }

    /// Display the favourites  in a grid with two columns that extend vertically
    @ViewBuilder
    private var favouritesGrid: some View {
        let columns = [GridItem(), GridItem()]
        LazyVGrid(columns: columns) {
            // Create an ImageBubble for each artwork that meets the filter criteria
            // and is a favourite
            ForEach(filteredArtists.0) { artist in
                ForEach(artist.artworks!) { artwork in
                    if (filteredArtists.1.contains(artwork.name) && favourites.contains(artwork.name)) {
                        NavigationLink(destination: ArtworkView(artwork: artwork)) {
                            ImageBubble(assetName: artwork.name + " 1",
                                        height: nil,
                                        width: 0.45 * width,
                                        fill: true)
                            .background(Color.theme.accent)
                            .cornerRadius(0.1 * min(height, width))
                        }
                    }
                }
            }
        }
    }

    /// Display the artwork's name in the list and a trailing heart image if the artwork is in the user's favourites
    private func artworkLabel(artworkName: String) -> some View {
        HStack {
            Text(artworkName)

            if favourites.contains(artworkName) {
                Spacer()
                Image(systemName: "heart.fill")
                    .foregroundColor(Color.theme.favourite)
            }
        }
    }

    /// Filter the artworks displayed by comparing text entered into the search bar to the artwork names
    private var filteredArtists: ([Artist], [String]) {
        // Array of artists who have an artwork that meets the filter criteria
        var filteredArtists: [Artist] = []
        // Array of artwork names that meet the filter criteria
        var filteredArtworks: [String] = []
        var alreadyFiltered: Bool = false

        artistManager.artists.forEach { artist in
            alreadyFiltered = false
            artist.artworks?.forEach { artwork in
                if artwork.name.localizedCaseInsensitiveContains(searchQuery) || searchQuery == "" {
                    filteredArtworks.append(artwork.name)
                    // Avoid adding the artist to the array more than once
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
