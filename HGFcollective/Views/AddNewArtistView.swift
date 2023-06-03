//
//  AddNewArtistView.swift
//  HGFcollective
//
//  Created by William Dolke on 29/05/2023.
//

import SwiftUI
import FirebaseAnalytics
import FirebaseFirestore

struct AddNewArtistView: View {
    @State private var artistName = ""
    @State private var biography = ""
    @State private var statusMessage = ""

    @FocusState private var isNameFocused: Bool
    @FocusState private var isBiographyFocused: Bool

    @EnvironmentObject var artistManager: ArtistManager
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Add a new artist")
                        .font(.title)
                    Spacer()
                }

                Image(systemName: "person.fill.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(colorScheme == .dark ? Color.theme.systemBackgroundInvert : Color.theme.accent)

                HStack {
                    Spacer()
                    Text("* = Required")
                        .font(.caption)
                        .foregroundColor(Color.theme.accentSecondary)
                }

                textFields

                Text("""
                     Tip: You can create an artist's artworks before you create the artist.
                     This will allow you to make the artist and their artworks appear to
                     users at the same time when you add the artist.
                     """)
                .font(.caption)

                Text(statusMessage)
                    .foregroundColor(Color.theme.favourite)

                submitButton
                    .alignmentGuide(.horizontalCenterAlignment, computeValue: { $0.width / 2.0 })
            }
            .padding()
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "\(AddNewArtistView.self)",
                                               AnalyticsParameterScreenClass: "\(AddNewArtistView.self)"])
            }
        }
    }

    /// Text fields for the user to enter information about the artist
    private var textFields: some View {
        Group {
            CustomTextField(title: "Artist name *", text: $artistName, isFocused: $isNameFocused) {
                isNameFocused = true
            }

            CustomTextField(title: "Biography *", text: $biography, isFocused: $isBiographyFocused) {
                isBiographyFocused = true
            }
        }
        .padding()
        .background(Color.theme.bubble)
        .cornerRadius(25)
        // Dismiss the keyboard with a downward drag gesture. The user can also dismiss the
        // keyboard by pressing the 'return' key.
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Ignore upward swipes
                    guard value.translation.height > 0 else { return }
                }
                .onEnded { _ in
                    UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.endEditing(true)
                }
        )
    }

    private var submitButton: some View {
        Button {
            logger.info("User tapped the submit button")
            createArtistIfDoesNotExist()
        } label: {
            HStack {
                Text("**Submit**")
                    .font(.title2)
                Image(systemName: "checkmark.icloud")
            }
            .padding()
            .foregroundColor(Color.theme.buttonForeground)
            .background(Color.theme.accent)
            .cornerRadius(40)
        }
        .contentShape(Rectangle())
        .padding(.bottom, 10)
    }

    private func createArtistIfDoesNotExist() {
        if artistName.isEmpty || biography.isEmpty {
            logger.info("User has not completed all required fields.")
            statusMessage = "Error: All fields are required and must be completed."
        } else {
            // Check if the artist already exists before attempting to add it. It is required that
            // the artist has a document at this path for it to exist and have associated artworks
            // displayed in the app.
            let artistPath = "artists/" + artistName
            let firestoreDB = Firestore.firestore()
            firestoreDB.checkDocumentExists(docPath: artistPath) { exists, error in
                if let error = error {
                    logger.error("Error checking if artist \(artistName) already exists: \(error)")
                } else {
                    if exists {
                        logger.info("User has attempted to add an artist that already exists: \(artistName)")
                        statusMessage = "Error: An artist with the name \(artistName) already exists."
                    } else {
                        logger.info("Artist \(artistName) does not already exist. Creating new artist.")
                        statusMessage = ""
                        let newArtistData = ["name": artistName, "biography": biography]
                        artistManager.createNewArtist(data: newArtistData)
                    }
                }
            }
        }
    }
}

struct AddNewArtistView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewArtistView()

        AddNewArtistView()
            .preferredColorScheme(.dark)
    }
}
