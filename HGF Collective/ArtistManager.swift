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
    
    // Create an instance of our Firestore database
    let db = Firestore.firestore()
    
    // On initialisation of the ArtistManager class, get the artists and artworks from Firestore
    init() {
        self.artists = []
        self.getArtists()
    }
    
    func getArtists() {
        print(" Getting artists.")
        db.collection("artists").addSnapshotListener { querySnapshot, error in
            
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
            self.getArtworks()
        }
    }
    
    func getArtworks() {
        print("Getting artworks.")
        for artist in self.artists {
            print("Current artwork for \(artist.name).")
            db.collection("artists").document(artist.name).collection("artworks").addSnapshotListener { [self] querySnapshot, error in
                
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
                            
                            // Return nil if we run into an error - but the compactMap will not include it in the final array
                            return nil
                        }
                    }
                }
            }
            print("Successfully got artworks.")
        }
    }
    
    func getArtworkImages() {
        
    }
    
    func getArtworkInfo(artwork: Artwork) -> Text {
        var info = Text("")
        
        if let text = artwork.editionNumber {
            info = info + Text("**Edition Number:** ") + Text("\(text)\n")
        }
        if let text = artwork.editionSize {
            info = info + Text("**Edition Size:** ") + Text("\(text)\n")
        }
        if let text = artwork.material {
            info = info + Text("**Materials:** ") + Text("\(text)\n")
        }
        if let text = artwork.dimensionUnframed {
            info = info + Text("**Dimensions Unframed:** ") + Text("\(text)\n")
        }
        if let text = artwork.dimensionFramed {
            info = info + Text("Dimensions Framed: ") + Text("\(text)\n")
        }
        if let text = artwork.year {
            info = info + Text("**Year of release:** ") + Text("\(text)\n")
        }
        if let text = artwork.signed {
            info = info + Text("**Signed:** ") + Text("\(text)\n")
        }
        if let text = artwork.numbered {
            info = info + Text("**Numbered:** ") + Text("\(text)\n")
        }
        if let text = artwork.stamped {
            info = info + Text("**Stamped:** ") + Text("\(text)\n")
        }
        if let text = artwork.authenticity {
            info = info + Text("**Certificate of authenticity:** ") + Text(text)
        }
        
        return info
    }
}
