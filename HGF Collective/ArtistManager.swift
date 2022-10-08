//
//  ArtistManager.swift
//  HGF Collective
//
//  Created by William Dolke on 13/09/2022.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

class ArtistManager: ObservableObject {
    @Published var artists: [Artist]
    @Published var featuredArtistIndex: Int?
    @Published var featuredArtistName: String?
    @Published var discoverArtworkIndex: Int?
    let numDiscoverArtworks: Int = 3

    // Create an instance of our Firestore database
    let firestoreDB = Firestore.firestore()

    // On initialisation of the ArtistManager class, get the artists and artworks from Firestore
    init() {
        self.artists = []
        self.getArtists()
    }

    func getArtists() {
        print("Getting artists.")
        firestoreDB.collection("artists").addSnapshotListener { querySnapshot, error in

            // If we don't have documents, exit the function
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }

            // Mapping through the documents
            self.artists = documents.compactMap { document -> Artist? in
                do {
                    // Converting each document into the Artist model
                    // Note that data(as:) is a function available only in FirebaseFirestoreSwift package
                    return try document.data(as: Artist.self)
                } catch {
                    // If we run into an error, print the error in the console
                    print("Error decoding document into Artist: \(error)")

                    // Return nil if we run into an error - but the compactMap will not include it in the final array
                    return nil
                }
            }
            self.featuredArtistIndex = Int.random(in: 0..<self.artists.count)
            self.featuredArtistName = self.artists[self.featuredArtistIndex!].name
            self.getArtworks()
        }
        print("Successfully got \(self.artists.count) artists.")
    }

    func getArtworks() {
        for artist in self.artists {
            print("Getting artworks for \(artist.name).")
            firestoreDB.collection("artists").document(artist.name).collection("artworks")
                .addSnapshotListener { [self] querySnapshot, error in

                // If we don't have documents, exit the function
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(String(describing: error))")
                    return
                }

                if let idx = self.artists.firstIndex(where: { $0.name == artist.name }) {
                    self.artists[idx].artworks = documents.compactMap { document -> Artwork? in
                        do {
                            // Converting each document into the Artwork model
                            return try document.data(as: Artwork.self)
                        } catch {
                            // If we run into an error, print the error in the console
                            print("Error decoding document into Artwork: \(error)")

                            // Return nil if we run into an error - but the compactMap will not include it in the final
                            // array
                            return nil
                        }
                    }
                    print("Got \(self.artists[idx].artworks?.count ?? 0) artworks for \(artist.name).")
                }
            }
        }
    }

    func getDiscoverArtworks() -> [Int] {
        var indexes: [Int] = []

        for num in 0...self.numDiscoverArtworks-1 {
            indexes.append(Int.random(in: 0..<self.artists.count))
            indexes.append(Int.random(in: 0..<self.artists[num].artworks!.count))
        }
        return indexes
    }

    func getArtworkImages() {

    }

    func getArtworkInfo(artwork: Artwork) -> Text {
        var info = ""

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
            info += "Dimensions Framed: \(text)\n"
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

        do {
            return try Text(AttributedString(markdown: info,
                                             options: AttributedString.MarkdownParsingOptions(interpretedSyntax:
                                                    .inlineOnlyPreservingWhitespace)))
        } catch {
            print("Couldn't convert artwork info to bold.")
            return Text(info)
        }
    }
}
