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
    @State private var segmentationSelection: ProfileSection = .grid
    @State private var showAddArtistOrArtworkView = false

    private let height = UIScreen.main.bounds.size.height
    private let width = UIScreen.main.bounds.size.width

    // Define the segmented control segments
    enum ProfileSection : String, CaseIterable {
        case grid = "Grid"
        case list = "List"
        case favourites = "Favourites"

        // Return the index of a case
        static func index(of aProfileSection: ProfileSection) -> Int {
            return ProfileSection.allCases.firstIndex(of: aProfileSection)!
        }

        // Return the value associated with a case
        static func element(at index: Int) -> ProfileSection? {
            if index >= 0 && index < ProfileSection.allCases.count {
                return ProfileSection.allCases[index]
            } else {
                return nil
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                segmentedControl
                chosenSegmentView()
            }
            .navigationTitle("Artworks")
            .toolbar {
                CustomToolbarItems(showView: $showAddArtistOrArtworkView)
            }
            .sheet(isPresented: $showAddArtistOrArtworkView) {
                AddNewArtistOrArtworkView()
                    .accentColor(Color.theme.navigationBarAccent)
            }
            .searchable(text: $searchQuery, prompt: "Search By Artwork Name")
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "\(ArtworksView.self)",
                                               AnalyticsParameterScreenClass: "\(ArtworksView.self)"])
            }
        }
    }

    /// Create the segmented picker from the enum cases
    private var segmentedControl: some View {
        SegmentedPicker(
            ProfileSection.allCases,
            selectedIndex: Binding(
                get: { ProfileSection.index(of: segmentationSelection) },
                set: { segmentationSelection = ProfileSection.element(at: $0 ?? 0) ?? .grid }),
            content: { segment, isActive in
                // Display the text for each segmentationControl case
                Text(segment.rawValue)
                    .foregroundColor(isActive ? Color.theme.systemBackgroundInvert : Color.theme.tabBarInactive)
                    .padding()
            },
            selection: {
                // Horizontal line under the active case
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.theme.systemBackgroundInvert)
                        .frame(height: 2)
                }
            }
        )
        .animation(.easeInOut(duration: 0.3))
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
                        NavigationLink(destination: ArtworkView(artistName: artist.name, artwork: artwork)) {
                            VStack {
                                ImageBubble(assetName: artwork.name + " 1",
                                            height: nil,
                                            width: 0.45 * width,
                                            fill: true)
                                .background(Color.theme.accent)
                                .cornerRadius(0.1 * min(height, width))
                                .overlay(
                                    favourites.contains(artwork.name) ? heart : nil
                                )

                                Text(artwork.name)
                                    .foregroundColor(Color.theme.systemBackgroundInvert)
                                HStack(spacing: 0) {
                                    Text(artist.name)
                                    if let year = artwork.year {
                                        Text(", \(year)")
                                    }
                                }
                                .font(.subheadline).italic()
                                .foregroundColor(Color.theme.systemBackgroundInvert)
                            }
                        }
                    }
                }
            }
        }
    }

    /// Display the filtered artworks in a list organised into sections by artist
    private var artworksList: some View {
        // Create a section for every artist who has an artwork that
        // meets the filter criteria
        ForEach(filteredArtists.0) { filteredArtist in
            HStack {
                Text(filteredArtist.name)
                    .font(.title).bold()
                    .foregroundColor(Color.theme.systemBackgroundInvert)
                    .padding([.horizontal, .top])
                Spacer()
            }

            // Add a navigationLink for every artwork by the artist
            // that meets the filter criteria
            ForEach(filteredArtist.artworks!) { artwork in
                if filteredArtists.1.contains(artwork.name) {
                    NavigationLink(destination: ArtworkView(artistName: filteredArtist.name, artwork: artwork)) {
                        VStack {
                            HStack {
                                CustomListRow(assetName: artwork.name + " 1", url: artwork.urls?[0], text: artwork.name)
                                if favourites.contains(artwork.name) {
                                    heart
                                } else {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color.theme.accent)
                                        .padding()
                                }
                            }
                            Divider()
                                .background(Color.theme.accentSecondary)
                        }
                    }
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
                        NavigationLink(destination: ArtworkView(artistName: artist.name, artwork: artwork)) {
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

    private var heart: some View {
        Image(systemName: "heart.fill")
            .foregroundColor(Color.theme.favourite)
            .padding()
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
