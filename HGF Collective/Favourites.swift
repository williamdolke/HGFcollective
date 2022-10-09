//
//  Favourites.swift
//  HGF Collective
//
//  Created by William Dolke on 09/10/2022.
//

import Foundation

class Favourites: ObservableObject {
    private var artworkNames: Set<String>

    // the key used to read/write in UserDefaults
    private let saveKey = "Favourites"

    init() {
        // load our saved data
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
                artworkNames = decoded
                return
            }
        }

        // Only executed if there is no saved data
        artworkNames = []
    }

    // returns true if our set contains this artwork
    func contains(_ artworkName: String) -> Bool {
        artworkNames.contains(artworkName)
    }

    // adds the artwork to our set, updates all views, and saves the change
    func add(_ artworkName: String) {
        objectWillChange.send()
        artworkNames.insert(artworkName)
        save()
    }

    // removes the artwork from our set, updates all views, and saves the change
    func remove(_ artworkName: String) {
        objectWillChange.send()
        artworkNames.remove(artworkName)
        save()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(artworkNames) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
}
