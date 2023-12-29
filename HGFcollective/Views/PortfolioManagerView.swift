//
//  PortfolioManagerView.swift
//  HGFcollective
//
//  Created by William Dolke on 30/05/2023.
//

import SwiftUI
import FirebaseAnalytics

struct PortfolioManagerView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            Form {
                addContentSection
                editContentSection
            }
            .navigationTitle("Add new content")
            .onAppear {
                logger.info("Presenting add new artist or artwork view.")

                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "\(PortfolioManagerView.self)",
                                               AnalyticsParameterScreenClass: "\(PortfolioManagerView.self)"])
            }
        }
    }

    private var addContentSection: some View {
        Section {
            NavigationLink(destination: AddNewArtworkView()) {
                HStack {
                    Image(systemName: "rectangle.center.inset.filled.badge.plus")
                        .foregroundColor(colorScheme == .dark ? Color.theme.systemBackgroundInvert : Color.theme.accent)
                    Text("Add a new artwork")
                }
            }
            NavigationLink(destination: AddNewArtistView()) {
                HStack {
                    Image(systemName: "person.fill.badge.plus")
                        .foregroundColor(colorScheme == .dark ? Color.theme.systemBackgroundInvert : Color.theme.accent)
                    Text("Add a new artist")
                }
            }
        } header: {
            Text("Select a type of content to add")
        }
    }

    private var editContentSection: some View {
        Section {
            NavigationLink(destination: EditArtworkView()) {
                HStack {
                    Image(systemName: "rectangle.center.inset.filled.badge.plus")
                        .foregroundColor(colorScheme == .dark ? Color.theme.systemBackgroundInvert : Color.theme.accent)
                    Text("Edit an existing artwork")
                }
            }
            NavigationLink(destination: EditArtistView()) {
                HStack {
                    Image(systemName: "person.fill.badge.plus")
                        .foregroundColor(colorScheme == .dark ? Color.theme.systemBackgroundInvert : Color.theme.accent)
                    Text("Edit an existing artist")
                }
            }
        } header: {
            Text("Select a type of content to edit")
        }
    }
}

struct PortfolioManagerView_Previews: PreviewProvider {
    static let artistManager = ArtistManager.shared

    static var previews: some View {
        PortfolioManagerView()
            .environmentObject(artistManager)

        PortfolioManagerView()
            .environmentObject(artistManager)
            .preferredColorScheme(.dark)
    }
}
