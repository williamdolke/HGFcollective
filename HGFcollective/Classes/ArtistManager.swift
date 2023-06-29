//
//  ArtistManager.swift
//  HGF Collective
//
//  Created by William Dolke on 13/09/2022.
//

import Foundation
import SwiftUI
import FirebaseCrashlytics
import FirebaseFirestore
import FirebaseStorage

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

            // Now the artists have been fetched we can begin fetching information about the
            // artworks and selecting the artists that will be on the home tab
            getArtworks()
            getFeaturedArtist()
            getDiscoverArtists()
        }
        logger.info("Successfully retrieved \(artists.count) artists.")
    }

    /// Fetch the artwork documents from the database for all artworks
    private func getArtworks() {
        logger.info("Retrieving artworks from database.")

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
        logger.info("Determining artists for Home screen discover section.")
        discoverArtistIndexes = getUniqueRandomNumbers(min: 0,
                                                       max: artists.count-1, count: numDiscoverArtists)
    }

    private func getFeaturedArtist() {
        // Select an artist to be featured at random
        featuredArtistIndex = Int.random(in: 0..<artists.count)
        repeat {
            featuredArtistIndex = Int.random(in: 0..<artists.count)
        } while (artists[featuredArtistIndex!].artworks?.isEmpty == true)
        featuredArtistName = artists[featuredArtistIndex!].name
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
            logger.error("Failed to convert artwork info to bold.")
            return Text(info)
        }
    }
    // swiftlint:enable cyclomatic_complexity

    /// Check if the artist already exists before attempting to add it. It is required that
    /// the artist has a document at this path for it to exist and have associated artworks
    /// displayed in the app.
    func createArtistIfDoesNotExist(name: String, biography: String, completion: @escaping (ActionResult?) -> Void) {
        let artistPath = "artists/" + name
        firestoreDB.checkDocumentExists(docPath: artistPath) { exists, error in
            if let error = error {
                logger.error("Error checking if artist \(name) already exists: \(error)")
                let result = ActionResult(success: false,
                                          message: "Error: An error occurred when checking if the artist already exists.")
                completion(result)
            } else {
                if exists {
                    logger.error("User has attempted to add an artist that already exists: \(name)")
                    let result = ActionResult(success: false,
                                              message: "Error: An artist with the name \(name) already exists.")
                    completion(result)
                } else {
                    logger.info("Artist \(name) does not already exist. Creating new artist.")
                    let newArtistData = ["name": name, "biography": biography]
                    // swiftlint:disable:next force_cast
                    self.firestoreDB.collection("artists").document(name)
                        .setData(newArtistData) { error in
                            if let error = error {
                                Crashlytics.crashlytics().record(error: error)
                                logger.error("Error creating new artist: \(error)")
                                let result = ActionResult(success: false,
                                                          message: "An error occurred when creating a new artist.")
                                completion(result)
                            } else {
                                logger.info("Successfully created new artist.")
                                let result = ActionResult(success: true,
                                                          message: "A new artist was successfully created.")
                                completion(result)
                            }
                        }
                }
            }
        }
    }

    func editArtistIfAlreadyExists(name: String, biography: String, completion: @escaping (ActionResult?) -> Void) {
        let artistPath = "artists/" + name
        firestoreDB.checkDocumentExists(docPath: artistPath) { exists, error in
            if let error = error {
                logger.error("Error checking if artist \(name) already exists: \(error)")
                let result = ActionResult(success: false,
                                          message: "Error: An error occurred when checking if the artist already exists.")
                completion(result)
            } else {
                if exists {
                    logger.info("Artist \(name) already exists. Editing artist document.")
                    let editArtistData = ["name": name, "biography": biography]
                    self.firestoreDB.collection("artists").document(name)
                        .setData(editArtistData, merge: false) { error in
                            if let error = error {
                                Crashlytics.crashlytics().record(error: error)
                                logger.error("Error editing artist document: \(error)")
                                let result = ActionResult(success: false,
                                                          message: "Error: An error occurred when editing an artist.")
                                completion(result)
                            } else {
                                logger.info("Successfully edited artist document.")
                                let result = ActionResult(success: true,
                                                          message: "An artist was successfully edited.")
                                completion(result)
                            }
                        }
                } else {
                    logger.error("User has attempted to edit an artist that already exists: \(name)")
                    let result = ActionResult(success: false,
                                              message: "Error: An artist with the name \(name) already exists.")
                    completion(result)
                }
            }
        }
    }

    func deleteArtist(artist: String) {
        logger.info("Deleting artist: \(artist)")

        // Documents in subcollections i.e. artwork documents are not deleted by this operation.
        // This allows admins to add all artworks for an artist without this being visible to
        // customers and finally add the artist to make then all appear at the same time.
        let docPath = "artists/" + artist
        firestoreDB.deleteDocument(docPath: docPath) { error in
            if let error = error {
                logger.error("Error deleting artist \(artist): \(error)")
            } else {
                logger.info("Artist \(artist) deleted successfully.")
                NavigationUtils.popToRootView()
            }
        }
    }

    /// Admins can add all the artworks for an artist without it being visible to users
    /// and finally add the artist to make then all appear in the app at the same time.
    func createNewArtwork(artist: String,
                          artwork: String,
                          data: [String: Any],
                          completion: @escaping (ActionResult?) -> Void) {
        logger.info("Creating new artwork.")

        firestoreDB.collection("artists").document(artist).collection("artworks").document(artwork)
            .setData(data) { error in
                if let error = error {
                    Crashlytics.crashlytics().record(error: error)
                    logger.error("Error creating new artwork: \(error)")
                    let result = ActionResult(success: false,
                                              message: "Error: An error occurred when creating a new artwork.")
                    completion(result)
                } else {
                    logger.info("Successfully created new artwork.")
                    let result = ActionResult(success: true,
                                              message: "A new artwork was successfully created.")
                    completion(result)
                }
            }
    }

    func editArtworkIfAlreadyExists(artist: String,
                                    artwork: String,
                                    data: [String:Any], completion: @escaping (ActionResult?) -> Void) {
        let artworkPath = "artists/" + artist + "/artworks/" + artwork
        firestoreDB.checkDocumentExists(docPath: artworkPath) { exists, error in
            if let error = error {
                logger.error("Error checking if artwork \(artwork) already exists for artist \(artist): \(error)")
                let result = ActionResult(success: false,
                                          message: "Error: An error occurred when checking if the artwork already exists.")
                completion(result)
            } else {
                if exists {
                    logger.info("Artwork \(artwork) already exists for artist \(artist). Editing artwork document.")
                    self.firestoreDB.collection("artists").document(artist).collection("artworks").document(artwork)
                        .setData(data, merge: false) { error in
                            if let error = error {
                                Crashlytics.crashlytics().record(error: error)
                                logger.error("Error editing artwork document: \(error)")
                                let result = ActionResult(success: false,
                                                          message: "Error: An error occurred when editing an artwork.")
                                completion(result)
                            } else {
                                logger.info("Successfully edited artwork document.")
                                let result = ActionResult(success: true,
                                                          message: "An artwork was successfully edited.")
                                completion(result)
                            }
                        }
                } else {
                    logger.error("User has attempted to edit an artwork that already exists: \(artwork)")
                    let result = ActionResult(success: false,
                                              message: "Error: An artwork with the name \(artwork) already exists for \(artist).")
                    completion(result)
                }
            }
        }
    }

    func deleteArtwork(artist: String, artwork: String, urls: [String]?) {
        logger.info("Deleting artwork: \(artwork) for artist: \(artist)")

        // Pop to root before deleting database documents and/or images to
        // avoid errors displaying images that don't exist anymore.
        // A crash was occurring when deleting an artwork that was navigated
        // to through the ArtistView when popping to root after everything
        // had been deleted.
        NavigationUtils.popToRootView()

        // If the artwork contains images that are not build into the app then
        // delete all the images from Storage if that's where they are located
        if let urls = urls {
            Storage.storage().deleteFiles(atURLs: urls)
        }

        // Delete the artwork document
        let docPath = "artists/" + artist + "/artworks/" + artwork
        firestoreDB.deleteDocument(docPath: docPath) { error in
            if let error = error {
                logger.error("Error deleting artwork \(artwork): \(error)")
            } else {
                logger.info("Artwork \(artwork) deleted successfully.")
            }
        }
    }
}

struct ActionResult {
    let success: Bool
    let message: String
}
