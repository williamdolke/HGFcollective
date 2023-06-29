//
//  EditArtworkView.swift
//  HGFcollective
//
//  Created by William Dolke on 22/06/2023.
//

import SwiftUI
import FirebaseAnalytics

struct EditArtworkView: View {
    // User input fields
    @State private var artistName = ""
    @State private var artworkName = ""
    @State private var description = ""
    @State private var urls: [String] = Array(repeating: "", count: Constants.maximumImages)
    @State private var editionNumber = ""
    @State private var editionSize = ""
    @State private var material = ""
    @State private var dimensionUnframed = ""
    @State private var dimensionFramed = ""
    @State private var year = ""
    @State private var signed = ""
    @State private var numbered = ""
    @State private var stamped = ""
    @State private var authenticity = ""
    @State private var price = ""

    @State private var statusMessage = ""

    // Sections
    @State private var isDetailExpanded = false

    @FocusState var artworkFieldInFocus: ArtworkField?

    @EnvironmentObject var artistManager: ArtistManager
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Edit an existing artwork")
                        .font(.title)
                    Spacer()
                }

                Image(systemName: "rectangle.center.inset.filled.badge.plus")
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
                .background(Color.theme.accent)

                if !artistName.isEmpty {
                    // Tag is an empty string so that the fields disappear when the user
                    // selects "Select an artist" rather than an artist from the database.
                    Picker("Select an artwork", selection: $artworkName) {
                        Text("Select an artwork").tag("")
                        ForEach(artistManager.artists.first(where: { $0.name == artistName })?.artworks ?? [Artwork(name: "No artworks")], id: \.name) { artwork in
                            Text(artwork.name).tag(artwork.name)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .background(Color.theme.accent)
                }

                if !artistName.isEmpty && !artworkName.isEmpty {
                    HStack {
                        Spacer()
                        Text("* = Required")
                            .font(.caption)
                            .foregroundColor(Color.theme.accentSecondary)
                    }

                    // Sections for the user to provide information/photos for the artwork
                    mainFields
                    detailSection

                    Text(statusMessage)
                        // TODO: Make a color for errors
                        .foregroundColor(Color.theme.favourite)

                    SubmitButton(action: editArtwork)
                        .alignmentGuide(.horizontalCenterAlignment, computeValue: { $0.width / 2.0 })
                }
            }
            .padding()
        }
        // Refresh the fields when the users selects a different artist
        .onChange(of: artistName) { artistName in
            artworkName = ""
        }
        .onChange(of: artworkName) { artworkName in
            if let artist = artistManager.artists.first(where: { $0.name == artistName }) {
                if let artwork = artist.artworks?.first(where: { $0.name == artworkName }) {
                    description = artwork.description ?? ""
                    urls = artwork.urls ?? []
                    editionNumber = artwork.editionNumber ?? ""
                    editionSize = artwork.editionSize ?? ""
                    material = artwork.material ?? ""
                    dimensionUnframed = artwork.dimensionUnframed ?? ""
                    dimensionFramed = artwork.dimensionFramed ?? ""
                    year = artwork.year ?? ""
                    signed = artwork.signed ?? ""
                    numbered = artwork.numbered ?? ""
                    stamped = artwork.stamped ?? ""
                    authenticity = artwork.authenticity ?? ""
                    price = artwork.price ?? ""
                }
            }
        }
        .onAppear {
            logger.info("Presenting edit artwork view.")

            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "\(EditArtworkView.self)",
                                           AnalyticsParameterScreenClass: "\(EditArtworkView.self)"])
        }
    }

    /// Text fields for the user to enter information about the artwork
    private var mainFields: some View {
        VStack {
            Group {
                CustomTextField(title: "Artist *",
                                   text: $artistName,
                                   focusedField: $artworkFieldInFocus,
                                   field: .artistName)
                .disabled(true)

                CustomTextField(title: "Title *",
                                   text: $artworkName,
                                   focusedField: $artworkFieldInFocus,
                                   field: .artworkName)
                .disabled(true)

                CustomTextField(title: "Description",
                                   text: $description,
                                   focusedField: $artworkFieldInFocus,
                                   field: .description)
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

            Text("""
                 The artist's or artwork's name cannot be edited.
                 """)
            .font(.caption)
        }
    }

    /// Attempt to edit the artwork. If the admin hasn't completed the required fields
    /// then this will not be successful and an error messge will be presented
    private func editArtwork() {
        // TODO: Allow photos to be edited
        // TODO: Check if the artwork already exists
        // Filter out any empty elements from urls. These correspond
        // to fields where the admin hasn't input anything.
        let nonEmptyURLs = urls.filter { !$0.isEmpty }

        if artworkName.isEmpty || nonEmptyURLs.isEmpty {
            logger.info("User has not completed all required fields.")
            statusMessage = "Error: All required and must be completed."
        } else {
            // TODO: Move to function
            // Use compactMap to remove any empty strings
            let properties: [(key: String, value: String)]  = [
                ("name", artworkName),
                ("description", description),
                ("editionNumber", editionNumber),
                ("editionSize", editionSize),
                ("material", material),
                ("dimensionUnframed", dimensionUnframed),
                ("dimensionFramed", dimensionFramed),
                ("year", year),
                ("signed", signed),
                ("numbered", numbered),
                ("stamped", stamped),
                ("authenticity", authenticity),
                ("price", price)
            ]
                .compactMap { key, value in
                    guard !value.isEmpty else { return nil }
                    return (key, value)
                }

            // Create a data object for the artwork being created
            var newArtworkData: [String:Any] = [:]
            for property in properties where !property.value.isEmpty {
                newArtworkData[property.key] = property.value
            }
            if !nonEmptyURLs.isEmpty {
                newArtworkData["urls"] = nonEmptyURLs
            }

            artistManager.editArtworkIfAlreadyExists(artist: artistName,
                                           artwork: artworkName,
                                           data: newArtworkData) { result in
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

    /// Fields for parameters that will be displayed in the Details section of ArtworkView
    private var detailSection: some View {
        VStack {
            sectionTitle(title: "Details", isExpanded: $isDetailExpanded)

            if isDetailExpanded {
                Group {
                    CustomTextField(title: "Edition number",
                                    text: $editionNumber,
                                    focusedField: $artworkFieldInFocus,
                                    field: .editionNumber)

                    CustomTextField(title: "Edition size",
                                    text: $editionSize,
                                    focusedField: $artworkFieldInFocus,
                                    field: .editionSize)

                    CustomTextField(title: "Unframed dimensions",
                                    text: $dimensionUnframed,
                                    focusedField: $artworkFieldInFocus,
                                    field: .dimensionUnframed)

                    CustomTextField(title: "Framed dimensions",
                                    text: $dimensionFramed,
                                    focusedField: $artworkFieldInFocus,
                                    field: .dimensionFramed)

                    CustomTextField(title: "Year",
                                    text: $year,
                                    focusedField: $artworkFieldInFocus,
                                    field: .yearCreated)

                    CustomTextField(title: "Signed",
                                    text: $signed,
                                    focusedField: $artworkFieldInFocus,
                                    field: .signed)

                    CustomTextField(title: "Numbered",
                                    text: $numbered,
                                    focusedField: $artworkFieldInFocus,
                                    field: .numbered)

                    CustomTextField(title: "Stamped",
                                    text: $stamped,
                                    focusedField: $artworkFieldInFocus,
                                    field: .stamped)

                    CustomTextField(title: "Authenticity",
                                    text: $authenticity,
                                    focusedField: $artworkFieldInFocus,
                                    field: .authenticity)

                    CustomTextField(title: "Price (include currency)",
                                    text: $price,
                                    focusedField: $artworkFieldInFocus,
                                    field: .price)
                }
                .padding()
                .background(Color.theme.bubble)
                .cornerRadius(25)
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
        }
    }

    private func sectionTitle(title: String, isExpanded: Binding<Bool>) -> some View {
        Button {
            withAnimation {
                isExpanded.wrappedValue.toggle()
            }
        } label: {
            HStack {
                Text(title)
                    .font(.headline)

                Spacer()

                Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(colorScheme == .dark ? Color.theme.systemBackgroundInvert : Color.theme.accent)
            .padding()
        }
    }
}

struct EditArtworkView_Previews: PreviewProvider {
    static let artistManager = ArtistManager()

    static var previews: some View {
        EditArtworkView()
            .environmentObject(artistManager)

        EditArtworkView()
            .environmentObject(artistManager)
            .preferredColorScheme(.dark)
    }
}
