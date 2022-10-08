//
//  ContentView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var artistManager: ArtistManager
    @EnvironmentObject var messagesManager: MessagesManager

    @State private var selection = 0
    @State var id: [Bool] = [false, false, false, false]

    var handler: Binding<Int> { Binding(
        get: { self.selection },
        set: {
            if $0 == self.selection {
                // Reset view
                id[self.selection].toggle()
            }
            self.selection = $0
        }
    )}

    var body: some View {
        TabView(selection: handler) {
            HomeView().id(id[self.selection])
                .environmentObject(artistManager)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            ArtistsView().id(id[self.selection])
                .environmentObject(artistManager)
                .tabItem {
                    Label("Artists", systemImage: "person.3")
                }
                .tag(1)
            ArtworksView().id(id[self.selection])
                .environmentObject(artistManager)
                .tabItem {
                    Label("Artworks", systemImage: "photo.artframe")
                }
                .tag(2)
            ContactView().id(id[self.selection])
                .environmentObject(messagesManager)
                .tabItem {
                    Label("Chat", systemImage: "bubble.left")
                }
                .tag(3)
        }.accentColor(Color.theme.accent)
    }
}

struct ContentView_Previews: PreviewProvider {
    static let artistManager = ArtistManager()
    static let messagesManager = MessagesManager(uid: "test")

    static var previews: some View {
        ContentView()
            .environmentObject(artistManager)
            .environmentObject(messagesManager)
    }
}
