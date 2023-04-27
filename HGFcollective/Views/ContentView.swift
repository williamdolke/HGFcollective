//
//  ContentView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI
import FirebaseAuth
import FirebaseAnalytics

struct ContentView: View {
    @EnvironmentObject var artistManager: ArtistManager
    @EnvironmentObject var tabBarState: TabBarState

    @StateObject var favourites = Favourites()

    // AppStorage is a property wrapper for accessing values stored in UserDefaults
    @AppStorage("aboutScreenShown")
    var aboutScreenShown: Bool = false
    // swiftlint:disable force_cast
    var messagesManager = MessagesManager(uid: UserDefaults.standard.object(forKey: "uid") as! String,
                                          notificationName: "CustomerUnreadMessageCountChanged")
    // swiftlint:enable force_cast
    var enquiryManager = EnquiryManager()

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
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor(Color.theme.accent)
        ], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor(Color.theme.navigationBarAccent)
        ], for: .normal)

        // Search bar colours
        // swiftlint:disable line_length
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor(Color.theme.systemBackground)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor(Color.theme.systemBackgroundInvert)
        // swiftlint:enable line_length
        let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor: UIColor(Color.theme.navigationBarAccent)]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
    }

    private var handler: Binding<Int> { Binding(
        get: { tabBarState.selection },
        set: {
            // Reset the view of the selected tab when the user
            // taps the active tab in the tab bar
            if $0 == tabBarState.selection {
                logger.info("User reset tab \(tabBarState.selection).")
                NavigationUtils.popToRootView()
            } else {
                tabBarState.selection = $0
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
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(0)
                ArtistsView()
                    .tabItem {
                        Label("Artists", systemImage: "person.3")
                    }
                    .tag(1)
                ArtworksView()
                    .tabItem {
                        Label("Artworks", systemImage: "photo.artframe")
                    }
                    .tag(2)
                customerOrAdminView()
                    .tabItem {
                        Label("Chat", systemImage: "bubble.left")
                    }
                    .tag(3)
                    .badge(tabBarState.unreadMessages)
            }
            .accentColor(Color.theme.navigationBarAccent)
            .toolbar(.visible, for: .tabBar)
            .toolbarBackground(Color.theme.tabBarBackground, for: .tabBar)
        }
        .environmentObject(artistManager)
        .environmentObject(enquiryManager)
        .environmentObject(favourites)
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "\(ContentView.self)",
                                           AnalyticsParameterScreenClass: "\(ContentView.self)"])
        }
    }

    @ViewBuilder
    private func customerOrAdminView() -> some View {
        if (UserDefaults.standard.value(forKey: "isAdmin") != nil) {
            NavigationView {
                InboxView()
                    .environmentObject(UserManager())
            }
        } else {
            ChatView()
                .environmentObject(messagesManager)
                // Update the badge count on the chat tab
                // swiftlint:disable line_length
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("CustomerUnreadMessageCountChanged"))) { _ in
                // swiftlint:enable line_length
                    if tabBarState.unreadMessages != messagesManager.unreadMessages {
                        logger.info("Setting the badge count on the chat tab to \(messagesManager.unreadMessages).")
                        tabBarState.unreadMessages = messagesManager.unreadMessages
                        UIApplication.shared.applicationIconBadgeNumber = messagesManager.unreadMessages
                    }
                }
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