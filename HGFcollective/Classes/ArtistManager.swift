//
//  ArtistManager.swift
//  HGF Collective
//
//  Created by William Dolke on 13/09/2022.
//

import Foundation
import FirebaseFirestore
import FirebaseCrashlytics
import FirebaseFirestoreSwift
import SwiftUI

class ArtistManager: ObservableObject {
    @Published var artists: [Artist] = []
    @Published var featuredArtistIndex: Int?
    @Published var featuredArtistName: String?
    @Published var discoverArtistIndexes: [Int]?

    // The number of artists that will be included in the discovery section
    let numDiscoverArtists: Int = 3

    // Create an instance of our Firestore database
    let firestoreDB = Firestore.firestore()

    // On initialisation of the ArtistManager class, get the artists and artworks from Firestore
    init() {
        self.getArtists()
    }

    /// Fetch all artist documents from the database
    private func getArtists() {
        logger.info("Retrieving artists from database.")
        // Read artists from Firestore in real-time with the addSnapShotListener
        firestoreDB.collection("artists").addSnapshotListener { [self] querySnapshot, error in
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                logger.error("Error fetching artist documents: \(error)")
                return
            }

            // Map the documents to Artist instances
            self.artists = (querySnapshot?.decodeDocuments() ?? []) as [Artist]

            // Select an artist to be featured at random
            featuredArtistIndex = Int.random(in: 0..<artists.count)
            repeat {
                featuredArtistIndex = Int.random(in: 0..<artists.count)
            } while (artists[featuredArtistIndex!].artworks?.isEmpty == true)
            featuredArtistName = artists[featuredArtistIndex!].name

            // Now the artists have been fetched we can begin fetching information about the
            // artworks and selecting the artists that will be on in the discovery section
            getDiscoverArtists()
            getArtworks()
        }
        logger.info("Successfully retrieved \(artists.count) artists.")
    }

    /// Fetch the artwork documents from the database for all artworks
    private func getArtworks() {
        for artist in artists {
            logger.info("Retrieving artworks for \(artist.name).")
            // Read artworks from Firestore in real-time with the addSnapShotListener
            firestoreDB.collection("artists").document(artist.name).collection("artworks")
                .addSnapshotListener { [self] querySnapshot, error in
                    if let error = error {
                        Crashlytics.crashlytics().record(error: error)
                        logger.error("Error fetching artwork documents: \(error)")
                        return
                    }

                    // Get the index of the artist that created the artwork that we are fetching
                    if let idx = artists.firstIndex(where: { $0.name == artist.name }) {
                        // Map the documents to Artwork instances
                        artists[idx].artworks = (querySnapshot?.decodeDocuments() ?? []) as [Artwork]

                        logger.info("Retrieved \(artists[idx].artworks?.count ?? 0) artworks for \(artist.name).")
                    }
            }
        }
    }

    /// Randomly select artists to be included in the discovery section. To do this we generate an array of
    /// unique random indexes that correspond to the indices of the selected artists in the array of all artists.
    private func getDiscoverArtists() {
        discoverArtistIndexes = getUniqueRandomNumbers(min: 0,
                                                       max: artists.count-1, count: numDiscoverArtists)
    }

    /// Generate an array of unique random integers from a range
    ///
    /// - Parameters:
    ///   -min: Minimum value that can be generated
    ///   -max: Maximum value that can be generated
    ///   -count: Number of unique integers to be generated
    func getUniqueRandomNumbers(min: Int, max: Int, count: Int) -> [Int] {
        // Use a set to avoid adding duplicates
        var set = Set<Int>()
        while set.count < count {
            set.insert(Int.random(in: min...max))
        }
        return Array(set)
    }

    // swiftlint:disable cyclomatic_complexity
    /// Create a text view that contains all information available about an artwork
    func getArtworkInfo(artwork: Artwork) -> Text? {
        var info = ""

        // Add all the information we have about an artwork to the text string
        if let text = artwork.editionNumber {
            info += "**Edition Number:** \(text)\n"
        }
        if let text = artwork.editionSize {
            info += "**Edition Size:** \(text)\n"
        }
        if let text = artwork.material {
            info += "**Materials:** \(text)\n"
        }
        if let text = artwork.dimensionUnframed {
            info += "**Dimensions Unframed:** \(text)\n"
        }
        if let text = artwork.dimensionFramed {
            info += "**Dimensions Framed:** \(text)\n"
        }
        if let text = artwork.year {
            info += "**Year of release:** \(text)\n"
        }
        if let text = artwork.signed {
            info += "**Signed:** \(text)\n"
        }
        if let text = artwork.numbered {
            info += "**Numbered:** \(text)\n"
        }
        if let text = artwork.stamped {
            info += "**Stamped:** \(text)\n"
        }
        if let text = artwork.authenticity {
            info += "**Certificate of authenticity:** \(text)"
        }

        // Make sure the string doesn't end in a newline
        if info.hasSuffix("\n") {
            info.removeLast()
        }

        if info == "" {
            return nil
        }

        // We need to parse the markdown (info) to interpret the text in asterisks as bold text
        do {
            return try Text(AttributedString(markdown: info,
                                             options: AttributedString.MarkdownParsingOptions(interpretedSyntax:
                                                    .inlineOnlyPreservingWhitespace)))
        } catch {
            Crashlytics.crashlytics().record(error: error)
            logger.error("Couldn't convert artwork info to bold.")
            return Text(info)
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
