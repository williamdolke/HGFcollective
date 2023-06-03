//
//  AddNewArtworkView.swift
//  HGFcollective
//
//  Created by William Dolke on 29/05/2023.
//

import SwiftUI
import FirebaseAnalytics
import PhotosUI

struct AddNewArtworkView: View {
    // User input fields
    @State private var artists: [Artist] = []
    @State private var artistName = ""
    @State private var artworkName = ""
    @State private var description = ""
    @State private var urls: [String] = []
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
    @State private var isPhotoExpanded = false
    @State private var isAdvancedExpanded = false

    // Photos
    private var limit = 10
    @State private var images = [UIImage]()
    @State private var showImagePicker = false
    @State private var compressionRatio: Double = 0.5

    @FocusState private var isArtworkNameFocused: Bool
    @FocusState private var isArtistNameFocused: Bool
    @FocusState private var isDescriptionFocused: Bool
    @FocusState private var isEditionNumberFocused: Bool
    @FocusState private var isEditionSizeFocused: Bool
    @FocusState private var isMaterialFocused: Bool
    @FocusState private var isDimensionUnframedFocused: Bool
    @FocusState private var isDimensionFramedFocused: Bool
    @FocusState private var isYearFocused: Bool
    @FocusState private var isSignedFocused: Bool
    @FocusState private var isNumberedFocused: Bool
    @FocusState private var isStampedFocused: Bool
    @FocusState private var isAuthenticityFocused: Bool
    @FocusState private var isPriceFocused: Bool

    @EnvironmentObject var artistManager: ArtistManager
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Add a new artwork")
                        .font(.title)
                    Spacer()
                }

                Image(systemName: "rectangle.center.inset.filled.badge.plus")
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
                detailSection
                photoSection
                advancedSection

                Text(statusMessage)
                    .foregroundColor(Color.theme.favourite)

                submitButton
                    .alignmentGuide(.horizontalCenterAlignment, computeValue: { $0.width / 2.0 })
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            MultipleImagePickerView(images: $images, limit: limit-images.count)
        }
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "\(AddNewArtworkView.self)",
                                           AnalyticsParameterScreenClass: "\(AddNewArtworkView.self)"])
        }
    }

    /// Text fields for the user to enter information about the artwork
    private var textFields: some View {
        VStack {
            Group {
                CustomTextField(title: "Artist *", text: $artistName, isFocused: $isArtistNameFocused) {
                    isArtistNameFocused = true
                }

                CustomTextField(title: "Title *", text: $artworkName, isFocused: $isArtworkNameFocused) {
                    isArtworkNameFocused = true
                }

                CustomTextField(title: "Description", text: $description, isFocused: $isDescriptionFocused) {
                    isDescriptionFocused = true
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
            Text("""
                 The artist field is case-sensitive and must be typed identically for all artworks by the same artist.
                 """)
            .font(.caption)
        }
    }

    private var submitButton: some View {
        Button {
            logger.info("User tapped the submit button.")

            // TODO: Update this logic
            if artworkName.isEmpty {
                logger.info("User has not completed all required fields.")
                statusMessage = "Error: All required and must be completed."
            } else {
                // TODO: Upload images to Storage if specified

                // TODO: Add urls to the data
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
                var newArtworkData: [String:String] = [:]
                for property in properties where !property.value.isEmpty {
                    newArtworkData[property.key] = property.value
                }
                artistManager.createNewArtwork(artist: artistName, artwork: artworkName, data: newArtworkData)
            }
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

    /// Fields for parameters that will be displayed in the Details section of ArtworkView
    private var detailSection: some View {
        VStack {
            sectionTitle(title: "Details", isExpanded: $isDetailExpanded)

            if isDetailExpanded {
                Group {
                    CustomTextField(title: "Edition number", text: $editionNumber, isFocused: $isEditionNumberFocused) {
                        isEditionNumberFocused = true
                    }

                    CustomTextField(title: "Edition size", text: $editionSize, isFocused: $isEditionSizeFocused) {
                        isEditionSizeFocused = true
                    }

                    CustomTextField(
                        title: "Unframed dimensions",
                        text: $dimensionUnframed,
                        isFocused: $isDimensionUnframedFocused
                    ) {
                        isDimensionUnframedFocused = true
                    }

                    CustomTextField(
                        title: "Framed dimensions",
                        text: $dimensionFramed,
                        isFocused: $isDimensionFramedFocused
                    ) {
                        isDimensionFramedFocused = true
                    }

                    CustomTextField(title: "Year", text: $year, isFocused: $isYearFocused) {
                        isYearFocused = true
                    }

                    CustomTextField(title: "Signed", text: $signed, isFocused: $isSignedFocused) {
                        isSignedFocused = true
                    }

                    CustomTextField(title: "Numbered", text: $numbered, isFocused: $isNumberedFocused) {
                        isNumberedFocused = true
                    }

                    CustomTextField(title: "Stamped", text: $stamped, isFocused: $isStampedFocused) {
                        isStampedFocused = true
                    }

                    CustomTextField(title: "Authenticity", text: $authenticity, isFocused: $isAuthenticityFocused) {
                        isAuthenticityFocused = true
                    }

                    CustomTextField(title: "Price", text: $price, isFocused: $isPriceFocused) {
                        isPriceFocused = true
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
        }
    }

    /// Section for the user to upload photos of the artwork or alternatively to specify URLs of images
    private var photoSection: some View {
        VStack {
            sectionTitle(title: "Photos", isExpanded: $isPhotoExpanded)

            if isPhotoExpanded {
                Group {
                    // Stop displaying the button when the limit is hit
                    if images.count < limit {
                        mediaButton
                    }

                    // Display selected images if the user has selected any
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(Array(images.enumerated()), id: \.1) { (index, image) in
                                ZStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 120)
                                    // Overlay a cross which lets the user delete the picture
                                    Button {
                                        logger.info("User pressed the close button to delete image \(index)")
                                        images.remove(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(Color.theme.favourite)
                                    }
                                }
                            }
                        }
                    }
                    Text("You can add up to 10 photos per artwork.")
                        .font(.caption)

                    // TODO: Let the user specify up to 10 links to images instead of uploading photos
                }
            }
            // TODO: Let URLs be defined instead of pictures being uploaded
        }
    }

    /// Button that opens the user's photo library and allows them to select photos of the artwork to upload
    private var mediaButton: some View {
        Button {
            showImagePicker.toggle()
            logger.info("User tapped the image picker button")
        } label: {
            HStack {
                Text("Select photos")
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundColor(Color.theme.buttonForeground)
                    .font(.system(size: 25))
            }
            .padding(10)
            .background(Color.theme.accent)
            .cornerRadius(50)
        }
    }

    /// Advanced section for anything that shouldn't normally be adjusted
    private var advancedSection: some View {
        VStack {
            sectionTitle(title: "Advanced", isExpanded: $isAdvancedExpanded)

            if isAdvancedExpanded {
                Group {
                    // Slider for the user to adjust the compression ratio applied to photos
                    // that they are uploading
                    Slider(value: $compressionRatio, in: 0...1, step: 0.01)
                        .accentColor(Color.theme.accent)
                    Text("Compression Ratio: \(compressionRatio, specifier: "%.2f")")
                        .font(.headline)

                    Text("""
                         Images are compressed by default when they are uploaded to improve \
                         performance. It is recommended that the compression ratio is not \
                         manually adjusted but it may be necessary for very high or low \
                         quality images.
                         """)
                    .font(.caption)
                    .padding()
                }
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

struct AddNewArtworkView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewArtworkView()

        AddNewArtworkView()
            .preferredColorScheme(.dark)
    }
}
