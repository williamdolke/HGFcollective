//
//  ContentView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI
import UIKit
import FirebaseAuth
import FirebaseAnalytics

struct ContentView: View {
    @EnvironmentObject var artistManager: ArtistManager

    @StateObject var favourites = Favourites()

    // TabBar state
    @State private var selection = 0

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
        get: { self.selection },
        set: {
            // Reset the view of the selected tab when the user
            // taps the active tab in the tab bar
            if $0 == self.selection {
                logger.info("User reset tab \(selection)")
                NavigationUtil.popToRootView()
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
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "\(ContentView.self)",
                                           AnalyticsParameterScreenClass: "\(ContentView.self)"])
        }
    }

    @ViewBuilder
    private func customerOrAdmin() -> some View {
        if (UserDefaults.standard.value(forKey: "isAdmin") != nil) {
            NavigationView {
                InboxView()
                    .environmentObject(UserManager())
            }
        } else {
            ChatView()
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

struct NavigationUtil {
  static func popToRootView() {
    findNavigationController(viewController: UIApplication.shared.windows.first?.rootViewController)?
      .popToRootViewController(animated: true)
  }

  static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
    guard let viewController = viewController else {
      return nil
    }

    if let navigationController = viewController as? UITabBarController {
      return findNavigationController(viewController: navigationController.selectedViewController)
    }

    if let navigationController = viewController as? UINavigationController {
      return navigationController
    }

    for childViewController in viewController.children {
      return findNavigationController(viewController: childViewController)
    }

    return nil
  }
}
