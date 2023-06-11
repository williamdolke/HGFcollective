//
//  AddNewArtistOrArtworkView.swift
//  HGFcollective
//
//  Created by William Dolke on 30/05/2023.
//

import SwiftUI
import FirebaseAnalytics

struct AddNewArtistOrArtworkView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            Form {
                contentTypeSection
            }
            .navigationTitle("Add new content")
            .onAppear {
                logger.info("Presenting add new artist or artwork view.")

                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "\(AddNewArtistOrArtworkView.self)",
                                               AnalyticsParameterScreenClass: "\(AddNewArtistOrArtworkView.self)"])
            }
        }
    }

    private var contentTypeSection: some View {
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
}

struct AddNewArtistOrArtworkView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewArtistOrArtworkView()

        AddNewArtistOrArtworkView()
            .preferredColorScheme(.dark)
    }
}
