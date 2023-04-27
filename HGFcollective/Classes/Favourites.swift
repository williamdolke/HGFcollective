//
//  Favourites.swift
//  HGF Collective
//
//  Created by William Dolke on 09/10/2022.
//

import Foundation

class Favourites: ObservableObject {
    private var artworkNames: Set<String> = []

    // The key used to read/write to UserDefaults
    private let saveKey = "Favourites"

    init() {
        // Load saved data from UserDefaults
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
                artworkNames = decoded
                return
            }
        }
    }

    /// Returns true if our set contains this artwork
    func contains(_ artworkName: String) -> Bool {
        artworkNames.contains(artworkName)
    }

    /// Adds the artwork to our set, updates all views and saves the change
    func add(_ artworkName: String) {
        objectWillChange.send()
        artworkNames.insert(artworkName)
        save()
    }

    /// Removes the artwork from our set, updates all views, and saves the change
    func remove(_ artworkName: String) {
        objectWillChange.send()
        artworkNames.remove(artworkName)
        save()
    }

    /// Save the set of artwork names to UserDefaults
    private func save() {
        if let encoded = try? JSONEncoder().encode(artworkNames) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
}
