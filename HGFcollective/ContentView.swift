//
//  ContentView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var artistManager: ArtistManager

    @StateObject var favourites = Favourites()

    // TabBar states
    @State private var selection = 0
    @State private var id: [Bool] = [false, false, false, false]

    // AppStorage is a property wrapper for accessing values stored in UserDefaults
    @AppStorage("aboutScreenShown")
    var aboutScreenShown: Bool = false

    init() {
        // Navigation bar colours
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.backgroundColor = UIColor(Color.theme.accent)
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor(Color.theme.navigationBarAccent)]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.theme.navigationBarAccent)]
        coloredAppearance.shadowColor = .clear

        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance

        // Tab bar colours
        UITabBar.appearance().backgroundColor = UIColor(Color.theme.tabBarBackground)
        UITabBar.appearance().barTintColor = UIColor(Color.theme.tabBarActive)
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.theme.tabBarInactive)

        // Segmented control colours
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.theme.navigationBarAccent)
        UISegmentedControl.appearance().backgroundColor = UIColor(Color.theme.accentSecondary)
        // swiftlint:disable line_length
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.theme.accent)], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.theme.navigationBarAccent)], for: .normal)

        // Search bar colours
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor(Color.theme.systemBackground)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor(Color.theme.systemBackgroundInvert)
        // swiftlint:enable line_length
        let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor: UIColor(Color.theme.navigationBarAccent)]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
    }

    private var handler: Binding<Int> { Binding(
        get: { self.selection },
        set: {
            // Reset the view of the selected tab when the user
            // taps the active tab in the tab bar
            if $0 == self.selection {
                logger.info("User reset tab \(selection)")
                id[self.selection].toggle()
            } else {
                self.selection = $0
            }
        }
    )}

    var body: some View {
        // Show the about screen if it has not been shown before i.e. on the app's
        // first launch. Otherwise, show the tabBar and associated views.
        if !aboutScreenShown {
            AboutView()
        } else {
            tabView
        }
    }

    private var tabView: some View {
        // Define the tabs in the tab bar
        TabView(selection: handler) {
            // Group the tabs so that colours can be applied to all of them
            Group {
                HomeView().id(id[self.selection])
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(0)
                    // Fix for a bug where HomeView navigationsLinks wouldn't work
                    // when id[0] is set to true
                    .onChange(of: id[0]) { _ in
                        id[0] = false
                    }
                ArtistsView().id(id[self.selection])
                    .tabItem {
                        Label("Artists", systemImage: "person.3")
                    }
                    .tag(1)
                ArtworksView().id(id[self.selection])
                    .tabItem {
                        Label("Artworks", systemImage: "photo.artframe")
                    }
                    .tag(2)
                customerOrAdmin()
                    .tabItem {
                        Label("Chat", systemImage: "bubble.left")
                    }
                    .tag(3)
                    .badge(1)
            }
            .accentColor(Color.theme.navigationBarAccent)
            .toolbar(.visible, for: .tabBar)
            .toolbarBackground(Color.theme.tabBarBackground, for: .tabBar)
        }
        .environmentObject(artistManager)
        .environmentObject(favourites)
    }

    @ViewBuilder
    private func customerOrAdmin() -> some View {
        if (UserDefaults.standard.value(forKey: "isAdmin") != nil) {
            NavigationView {
                InboxView()
                    .environmentObject(UserManager())
            }
        } else {
            ChatView().id(id[self.selection])
                // swiftlint:disable force_cast
                .environmentObject(MessagesManager(uid: UserDefaults.standard.object(forKey: "uid") as! String))
                // swiftlint:enable force_cast
                .environmentObject(EnquiryManager())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let artistManager = ArtistManager()

    static var previews: some View {
        ContentView()
            .environmentObject(artistManager)

        ContentView()
            .environmentObject(artistManager)
            .preferredColorScheme(.dark)
    }
}
