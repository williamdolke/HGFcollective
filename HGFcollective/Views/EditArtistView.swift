//
//  EditArtistView.swift
//  HGFcollective
//
//  Created by William Dolke on 22/06/2023.
//

import SwiftUI
import FirebaseAnalytics

struct EditArtistView: View {
    @EnvironmentObject var artistManager: ArtistManager
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    @State private var artistName = ""
    @State private var biography = ""
    @State private var statusMessage = ""
    @State private var selectedArtist = ""

    @FocusState private var isFieldFocused: NewArtistField?

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Edit existing artist")
                        .font(.title)
                    Spacer()
                }

                Image(systemName: "person.fill.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(colorScheme == .dark ? Color.theme.systemBackgroundInvert : Color.theme.accent)

                // Tag is an empty string so that the fields disappear when the user
                // selects "Select an artist" rather than an artist from the database.
                // Label is for voiceover.
                Picker("Select an artist", selection: $artistName) {
                    Text("Select an artist").tag("")
                    ForEach(artistManager.artists, id: \.name) { artist in
                        Text(artist.name).tag(artist.name)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .accentColor(Color.theme.buttonForeground)
                .background(Color.theme.accent)

                if !artistName.isEmpty {
                    HStack {
                        Spacer()
                        Text("* = Required")
                            .font(.caption)
                            .foregroundColor(Color.theme.accentSecondary)
                    }

                    textFields

                    Text("""
                         The artist's name cannot be edited.
                         """)
                    .font(.caption)

                    Text(statusMessage)
                        .foregroundColor(Color.theme.error)

                    SubmitButton(action: editArtistIfAlreadyExists)
                        .alignmentGuide(.horizontalCenterAlignment, computeValue: { $0.width / 2.0 })
                }
            }
            .padding()
        }
        // Refresh the fields when the users selects a different artist
        .onChange(of: artistName) { artistName in
            if let artist = artistManager.artists.first(where: { $0.name == artistName }) {
                biography = artist.biography
            }
        }
        .onAppear {
            logger.info("Presenting edit artist view.")

            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "\(EditArtistView.self)",
                                           AnalyticsParameterScreenClass: "\(EditArtistView.self)"])
        }
    }

    /// Text fields for the user to enter information about the artist
    private var textFields: some View {
        Group {
            // It's possible to edit an artist name by changing the name field in the document but this adds
            // complications that are not yet handled, therefore don't let the user edit this field.
            CustomTextField(title: "Artist name *", text: $artistName, focusedField: $isFieldFocused, field: .name)
                .disabled(true)

            CustomTextField(title: "Biography *", text: $biography, focusedField: $isFieldFocused, field: .biography)
        }
        .padding()
        .background(Color.theme.bubble)
        .cornerRadius(25)
        .keyboardDismissGesture()
    }

    private func editArtistIfAlreadyExists() {
        if artistName.isEmpty || biography.isEmpty {
            logger.info("User has not completed all required fields.")
            statusMessage = "Error: All fields are required and must be completed."
        } else {
            artistManager.editArtistIfAlreadyExists(name: artistName, biography: biography) { result in
                if let result = result {
                    statusMessage = result.message
                    // Go back to the portfolio manager menu if successful
                    if result.success == true {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct EditArtistView_Previews: PreviewProvider {
    static let artistManager = ArtistManager()

    static var previews: some View {
        EditArtistView()
            .environmentObject(artistManager)

        EditArtistView()
            .environmentObject(artistManager)
            .preferredColorScheme(.dark)
    }
}
