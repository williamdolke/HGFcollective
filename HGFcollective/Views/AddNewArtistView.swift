//
//  AddNewArtistView.swift
//  HGFcollective
//
//  Created by William Dolke on 29/05/2023.
//

import SwiftUI
import FirebaseAnalytics

enum NewArtistField: Hashable {
    case name
    case biography
}

struct AddNewArtistView: View {
    @EnvironmentObject var artistManager: ArtistManager
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    @State private var artistName = ""
    @State private var biography = ""
    @State private var statusMessage = ""

    @FocusState private var isFieldFocused: NewArtistField?

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

                SubmitButton(action: createArtistIfDoesNotExist)
                    .alignmentGuide(.horizontalCenterAlignment, computeValue: { $0.width / 2.0 })
            }
            .padding()
        }
        .onAppear {
            logger.info("Presenting add new artist view.")

            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "\(AddNewArtistView.self)",
                                           AnalyticsParameterScreenClass: "\(AddNewArtistView.self)"])
        }
    }

    /// Text fields for the user to enter information about the artist
    private var textFields: some View {
        Group {
            CustomTextField(title: "Artist name *", text: $artistName, focusedField: $isFieldFocused, field: .name)

            CustomTextField(title: "Biography *", text: $biography, focusedField: $isFieldFocused, field: .biography)
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

    private func createArtistIfDoesNotExist() {
        if artistName.isEmpty || biography.isEmpty {
            logger.info("User has not completed all required fields.")
            statusMessage = "Error: All fields are required and must be completed."
        } else {
            artistManager.createArtistIfDoesNotExist(name: artistName, biography: biography) { result in
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

struct AddNewArtistView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewArtistView()

        AddNewArtistView()
            .preferredColorScheme(.dark)
    }
}
