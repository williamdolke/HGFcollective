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
        firestoreDB.collection("artists").addSnapshotListener { querySnapshot, error in

            // If we don't have documents, exit the function
            guard let documents = querySnapshot?.documents else {
                Crashlytics.crashlytics().record(error: error!)
                logger.error("Error fetching documents: \(String(describing: error))")
                return
            }

            // Map the documents to Artist instances
            self.artists = documents.compactMap { document -> Artist? in
                do {
                    // Convert each document into the Artist model
                    return try document.data(as: Artist.self)
                } catch {
                    Crashlytics.crashlytics().record(error: error)
                    logger.error("Error decoding document into Artist: \(error)")

                    // Return nil if we run into an error - the compactMap will
                    // not include it in the final array
                    return nil
                }
            }
            // Select an artist to be featured at random
            self.featuredArtistIndex = Int.random(in: 0..<self.artists.count)
            self.featuredArtistName = self.artists[self.featuredArtistIndex!].name

            // Now the artists have been fetched we can begin fetching information about the
            // artworks and selecting the artists that will be on in the discovery section
            self.getDiscoverArtists()
            self.getArtworks()
        }
        logger.info("Successfully retrieved \(self.artists.count) artists.")
    }

    /// Fetch the artwork documents from the database for all artworks
    private func getArtworks() {
        for artist in self.artists {
            logger.info("Retrieving artworks for \(artist.name).")
            // Read artworks from Firestore in real-time with the addSnapShotListener
            firestoreDB.collection("artists").document(artist.name).collection("artworks")
                .addSnapshotListener { [self] querySnapshot, error in

                // If we don't have documents, exit the function
                guard let documents = querySnapshot?.documents else {
                    Crashlytics.crashlytics().record(error: error!)
                    logger.error("Error fetching documents: \(String(describing: error))")
                    return
                }

                // Get the index of the artist that created the artwork that we are fetching
                if let idx = self.artists.firstIndex(where: { $0.name == artist.name }) {
                    self.artists[idx].artworks = documents.compactMap { document -> Artwork? in
                        do {
                            // Convert each document into the Artwork model
                            return try document.data(as: Artwork.self)
                        } catch {
                            Crashlytics.crashlytics().record(error: error)
                            logger.error("Error decoding document into Artwork: \(error)")

                            // Return nil if we run into an error - the compactMap will not include it in the final
                            // array
                            return nil
                        }
                    }
                    logger.info("Retrieved \(self.artists[idx].artworks?.count ?? 0) artworks for \(artist.name).")
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
    private func getUniqueRandomNumbers(min: Int, max: Int, count: Int) -> [Int] {
        // Use a set to avoid adding duplicates
        var set = Set<Int>()
        while set.count < count {
            set.insert(Int.random(in: min...max))
        }
        return Array(set)
    }

    /// Create a text view that contains all information available about an artwork
    // swiftlint:disable cyclomatic_complexity
    func getArtworkInfo(artwork: Artwork) -> Text {
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
