//
//  ArtistsView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI
import FirebaseAnalytics

struct ArtistsView: View {
    @EnvironmentObject var artistManager: ArtistManager

    @State private var searchQuery = ""
    @State private var segmentationSelection: ProfileSection = .grid
    private let height = UIScreen.main.bounds.size.height
    private let width = UIScreen.main.bounds.size.width

    // Define the segmented control segments
    enum ProfileSection : String, CaseIterable {
        case grid = "Grid"
        case list = "List"

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
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "\(ArtistsView.self)",
                                               AnalyticsParameterScreenClass: "\(ArtistsView.self)"])
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
            artistsGrid
        case .list:
            artistsList
        }
    }

    /// Display the filtered artists in a grid with two columns that extend vertically
    @ViewBuilder
    private var artistsGrid: some View {
        let columns = [GridItem(), GridItem()]
        LazyVGrid(columns: columns) {
            // Create an ImageBubble for each artist that meets the filter criteria
            ForEach(filteredArtists) { artist in
                let artwork = (artist.artworks?.isEmpty == false) ? artist.artworks![0] : Artwork(name: "")
                NavigationLink(destination: ArtistView(artist: artist)) {
                    VStack {
                        ImageBubble(assetName: artwork.name + " 1",
                                    height: nil,
                                    width: 0.45 * width,
                                    fill: true)
                        .background(Color.theme.accent)
                        .cornerRadius(0.1 * min(height, width))

                        Text(artist.name)
                    }
                }
            }
        }
    }

    /// Display the filtered artists in a list
    private var artistsList: some View {
        // Add a navigationLink for every artist that meets the filter criteria
        ForEach(filteredArtists) { artist in
            let noArtworks = artist.artworks?.isEmpty
            let artworkAssetName = (noArtworks == false) ? artist.artworks![0].name + " 1" : ""
            let artworkURL = (noArtworks == false) ? artist.artworks![0].urls?[0] : nil

            NavigationLink(destination: ArtistView(artist: artist)) {
                VStack {
                    HStack {
                        CustomListRow(assetName: artworkAssetName, url: artworkURL, text: artist.name)
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.theme.accent)
                            .padding()
                    }
                    Divider()
                        .background(Color.theme.accentSecondary)
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
