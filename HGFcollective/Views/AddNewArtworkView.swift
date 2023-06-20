//
//  AddNewArtworkView.swift
//  HGFcollective
//
//  Created by William Dolke on 29/05/2023.
//

import SwiftUI
import FirebaseAnalytics
import FirebaseStorage
import PhotosUI

struct AddNewArtworkView: View {
    // User input fields
    @State private var artists: [Artist] = []
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
    @State private var isPhotoExpanded = false
    @State private var isAdvancedExpanded = false

    // Photos
    @State private var images = [UIImage]()
    @State private var showImagePicker = false
    @State private var compressionRatio: Double = 0.5

    enum ArtworkField: Hashable {
        case artworkName
        case artistName
        case description
        case editionNumber
        case editionSize
        case material
        case dimensionUnframed
        case dimensionFramed
        case yearCreated
        case signed
        case numbered
        case stamped
        case authenticity
        case price
    }

    enum UrlField: Int, Hashable, CaseIterable {
        case url1
        case url2
        case url3
        case url4
        case url5
        case url6
        case url7
        case url8
        case url9
        case url10
    }

    @FocusState var artworkFieldInFocus: ArtworkField?
    @FocusState var urlFieldInFocus: UrlField?

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

                // Sections for the user to provide information/photos for the artwork
                mainFields
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
            MultipleImagePickerView(images: $images, limit: Constants.maximumImages-images.count)
        }
        .onAppear {
            logger.info("Presenting add new artwork view.")

            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "\(AddNewArtworkView.self)",
                                           AnalyticsParameterScreenClass: "\(AddNewArtworkView.self)"])
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

                CustomTextField(title: "Title *",
                                   text: $artworkName,
                                   focusedField: $artworkFieldInFocus,
                                   field: .artworkName)

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
                 The artist field is case-sensitive and must be typed identically for all artworks by the same artist.
                 """)
            .font(.caption)
        }
    }

    /// Button to compile all the information/photos provided and add the artwork to the database.
    /// This includes the upload of photos to storage and including references to their locations in
    /// the artwork document
    private var submitButton: some View {
        Button {
            logger.info("User tapped the submit button.")
            createArtwork()
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
            .shadow(radius: 8, x: 8, y: 8)
        }
        .contentShape(Rectangle())
        .padding(.bottom, 10)
    }

    /// Attempt to create the artwork. If the admin hasn't completed the required fields/uploaded
    /// images then this will not be successful and an error messge will be presented
    private func createArtwork() {
        // TODO: Check if the artwork already exists
        // Filter out any empty elements from urls. These correspond
        // to fields where the admin hasn't input anything.
        let nonEmptyURLs = urls.filter { !$0.isEmpty }

        // Require that there is a name defined as well as either photo(s) from camera roll or image URL(s)
        if !images.isEmpty && !nonEmptyURLs.isEmpty {
            logger.info("User has provided both camera roll photo(s) and image URL(s).")
            statusMessage = "Error: Provide either photos from your camera roll or URLs of images."
        } else if artworkName.isEmpty || (images.isEmpty && nonEmptyURLs.isEmpty) {
            logger.info("User has not completed all required fields.")
            statusMessage = "Error: All required and must be completed."
        } else {
            // TODO: Move to function
            let dispatchGroup = DispatchGroup()
            var storageURLs: [String] = []
            // Upload images to Storage if specified
            for (index, image) in images.enumerated() {
                logger.info("Uploading new artwork image to Storage.")

                // Create the path where the image will be stored in storage
                // swiftlint:disable:next line_length
                let storagePath = "artists/" + artistName + "/artworks/" + artworkName + "/" + artworkName + " " + String(index+1)

                // Convert the image to jpeg format and compress
                guard let imageData = image.jpegData(compressionQuality: compressionRatio) else { return }

                dispatchGroup.enter() // Notify the group that a task has started

                Storage.storage().uploadData(path: storagePath, data: imageData) { storageURL in
                    if let storageURL = storageURL {
                        storageURLs.append(storageURL)
                    }
                    dispatchGroup.leave() // Notify the group that a task has completed
                }
            }

            dispatchGroup.notify(queue: .main) {
                // Code to execute once all tasks are completed
                logger.info("All images have finished uploading.")
                logger.info("Storage URLs: \(storageURLs)")

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
                } else if !storageURLs.isEmpty {
                    newArtworkData["urls"] = storageURLs
                }

                artistManager.createNewArtwork(artist: artistName, artwork: artworkName, data: newArtworkData)
            }
        }
    }

    /// Fields for parameters that will be displayed in the Details section of ArtworkView
    private var detailSection: some View {
        VStack {
            sectionTitle(title: "Details", isExpanded: $isDetailExpanded)

            if isDetailExpanded {
                let detailFields = [
                    CustomTextField(title: "Edition number",
                                    text: $editionNumber,
                                    focusedField: $artworkFieldInFocus,
                                    field: .editionNumber),

                    CustomTextField(title: "Edition size",
                                    text: $editionSize,
                                    focusedField: $artworkFieldInFocus,
                                    field: .editionSize),

                    CustomTextField(title: "Unframed dimensions",
                                    text: $dimensionUnframed,
                                    focusedField: $artworkFieldInFocus,
                                    field: .dimensionUnframed),

                    CustomTextField(title: "Framed dimensions",
                                    text: $dimensionFramed,
                                    focusedField: $artworkFieldInFocus,
                                    field: .dimensionFramed),

                    CustomTextField(title: "Year",
                                    text: $year,
                                    focusedField: $artworkFieldInFocus,
                                    field: .yearCreated),

                    CustomTextField(title: "Signed",
                                    text: $signed,
                                    focusedField: $artworkFieldInFocus,
                                    field: .signed),

                    CustomTextField(title: "Numbered",
                                    text: $numbered,
                                    focusedField: $artworkFieldInFocus,
                                    field: .numbered),

                    CustomTextField(title: "Stamped",
                                    text: $stamped,
                                    focusedField: $artworkFieldInFocus,
                                    field: .stamped),

                    CustomTextField(title: "Authenticity",
                                    text: $authenticity,
                                    focusedField: $artworkFieldInFocus,
                                    field: .authenticity),

                    CustomTextField(title: "Price (include currency)",
                                    text: $price,
                                    focusedField: $artworkFieldInFocus,
                                    field: .price)
                ]

                Group {
                    ForEach(detailFields, id: \.self) { detailField in
                        detailField
                    }
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

    /// Section for the user to upload photos of the artwork or alternatively to specify URLs of images
    private var photoSection: some View {
        VStack {
            sectionTitle(title: "Photos *", isExpanded: $isPhotoExpanded)

            if isPhotoExpanded {
                Group {
                    // Stop displaying the button when the limit is hit
                    if images.count < Constants.maximumImages {
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
                    Text("""
                         You can add up to \(Constants.maximumImages) photos per artwork.
                         Alternatively, you can provide up to \(Constants.maximumImages) \
                         links to images from the internet.
                         """)
                        .font(.caption)

                    urlSection
                }
            }
        }
    }

    // Show one text field more that the user has filled out up to a maximum number
    private var urlSection: some View {
        let filteredURLs = urls.filter { !$0.isEmpty }
        let urlCount = min(filteredURLs.count + 1, Constants.maximumImages)

        let textFields = (0..<urlCount).map { index in
            CustomTextField(title: "URL of image \(index + 1)",
                            text: $urls[index],
                            focusedField: $urlFieldInFocus,
                            field: UrlField.allCases[index])
        }

        return VStack {
            Group {
                ForEach(textFields, id: \.self) { textField in
                    textField
                }
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

    /// Button that opens the user's photo library and allows them to select photos of the artwork to upload
    private var mediaButton: some View {
        Button {
            showImagePicker.toggle()
            logger.info("User tapped the image picker button")
        } label: {
            HStack {
                Text("**Select photos**")
                    .font(.title2)
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
