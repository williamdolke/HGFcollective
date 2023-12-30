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

    @State private var images: [Asset] = []
    @State private var minImagesAllowed: Int?
    @State private var manuallyDeletedImages: [String] = []
    @State private var cameraRollImages = [UIImage]()
    @State private var showImagePicker = false
    @State private var draggedImage: Asset?
    @State private var compressionRatio: Double = 0.5

    @State private var statusMessage = ""

    @State private var isLoading = false

    // Sections
    @State private var isDetailExpanded = false
    @State private var isPhotosExpanded = false
    @State private var isAdvancedExpanded = false

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
                .accentColor(Color.theme.buttonForeground)
                .background(Color.theme.accent)

                if !artistName.isEmpty {
                    // Tag is an empty string so that the fields disappear when the user
                    // selects "Select an artist" rather than an artist from the database.
                    Picker("Select an artwork", selection: $artworkName) {
                        Text("Select an artwork").tag("")
                        let artworks = artistManager.artists.first(where: { $0.name == artistName })?.artworks
                        ForEach(artworks ?? [Artwork(name: "No artworks")], id: \.name) { artwork in
                            Text(artwork.name).tag(artwork.name)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(Color.theme.buttonForeground)
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
                    photosSection
                    advancedSection

                    Text(statusMessage)
                        .foregroundColor(Color.theme.error)

                    SubmitButton(action: editArtwork)
                        .alignmentGuide(.horizontalCenterAlignment, computeValue: { $0.width / 2.0 })
                }
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            MultipleImagePickerView(images: $cameraRollImages,
                                    limit: Constants.maximumImages - images.count - cameraRollImages.count)
        }
        // Show a spinner when performing async tasks
        .overlay {
            if isLoading {
                ActivityIndicator()
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color.theme.accent)
            }
        }
        // Refresh the fields when the users selects a different artist
        .onChange(of: artistName) { _ in
            artworkName = ""
        }
        .onChange(of: artworkName) { _ in
            handleArtworkNameChanged()
        }
        .onChange(of: cameraRollImages) { _ in
            for image in cameraRollImages {
                // Worry about the correct assetName and index later. For now we only care about storing off the image.
                let asset = Asset(assetName: "", index: 0, uiImage: image, changed: true)
                images.append(asset)
            }
            cameraRollImages = []
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
            .keyboardDismissGesture()

            Text("""
                 The artist's or artwork's name cannot be edited.
                 """)
            .font(.caption)
        }
    }

    /// Fields for parameters that will be displayed in the Details section
    private var detailSection: some View {
        VStack {
            SectionTitle(title: "Details", isExpanded: $isDetailExpanded)

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
                .keyboardDismissGesture()
            }
        }
    }

    /// Fields for parameters that will be displayed in the Photos section
    private var photosSection: some View {
        // TODO: Add URL section
        VStack {
            SectionTitle(title: "Photos *", isExpanded: $isPhotosExpanded)

            if isPhotosExpanded {
                if !images.isEmpty {
                    Text("""
                 Drag photos to reorder them.
                 """)
                    .font(.caption)

                    Group {
                        ScrollView(.horizontal) {
                            HStack {
                                currentImages
                            }
                        }
                    }
                    .padding()
                    .background(Color.theme.bubble)
                    .cornerRadius(25)
                }

                // Stop displaying the button when the limit is hit
                if images.count + cameraRollImages.count < Constants.maximumImages {
                    SelectPhotosButton(action: {showImagePicker.toggle()})
                }

                Text("""
                 You can add up to \(Constants.maximumImages) photos per artwork.
                 Photos that are built into the app can be overriden but cannot be removed \
                 i.e. a replacement image must be provided to display in its place.
                 """)
                .font(.caption)
            }
        }
    }

    private var currentImages: some View {
        ForEach(images.indices, id: \.self) { index in
            ZStack {
                ImageBubble(assetName: images[index].assetName,
                            url: images[index].url,
                            uiImage: images[index].uiImage,
                            height: 100,
                            width: nil)
                .onDrag {
                    self.draggedImage = images[index]
                    return NSItemProvider()
                }
                .onDrop(of: [.text],
                        delegate: DropViewDelegate(destinationItem: images[index],
                                                   images: $images,
                                                   draggedItem: $draggedImage)
                )
#if DEBUG
                Text("\(index), \(images[index].index), \(images[index].changed == true ? "true" : "false")")
                    .background(Color.theme.systemBackground)
                    .foregroundColor(Color.theme.accent)
#endif

                // Overlay a cross which lets the user delete the picture
                Button {
                    logger.info("User pressed the close button to delete image \(index)")
                    // We need to record the urls of images that the user deletes so we can
                    // potentially clean them up later
                    if let urlToDelete = images[index].url, !urlToDelete.isEmpty {
                        manuallyDeletedImages.append(urlToDelete)
                    }
                    images.remove(at: index)
                } label: {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.theme.favourite)
                    }
                }
            }
        }
    }

    /// Advanced section for anything that shouldn't normally be adjusted
    private var advancedSection: some View {
        VStack {
            SectionTitle(title: "Advanced", isExpanded: $isAdvancedExpanded)

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

    /// Attempt to edit the artwork. If the admin hasn't completed the required fields
    /// then this will not be successful and an error messge will be presented
    private func editArtwork() {
        // TODO: Check if the artwork already exists
        // TODO: Allow a mix of URLs and camera-roll images to be used
        statusMessage = ""

        // Only update the indices if the user presses submit for efficiency.
        for index in 0..<images.count where images[index].index != index + 1 {
            images[index].index = index + 1
        }

        // Filter out any empty elements from urls. These correspond
        // to fields where the admin hasn't input anything.
        let nonEmptyURLs = urls.filter { !$0.isEmpty }

        // Require that there is a name defined
        if artworkName.isEmpty || (images.isEmpty && nonEmptyURLs.isEmpty) {
            logger.info("User has not completed all required fields.")
            statusMessage = "Error: All required and must be completed."
        } else if ((minImagesAllowed != nil) && images.count < minImagesAllowed!) {
            logger.info("User has not provided enough images.")
            statusMessage = """
                            Error: Not enough images have been provided. It is likely that built-in \
                            images have been deleted without a replacement image being provided.
                            """
        } else {
            isLoading = true

            let editedArtworkData = artistManager.createArtworkData(name: artworkName,
                                                                    description: description,
                                                                    editionNumber: editionNumber,
                                                                    editionSize: editionSize,
                                                                    material: material,
                                                                    dimensionUnframed: dimensionUnframed,
                                                                    dimensionFramed: dimensionFramed,
                                                                    year: year,
                                                                    signed: signed,
                                                                    numbered: numbered,
                                                                    stamped: stamped,
                                                                    authenticity: authenticity,
                                                                    price: price)

            artistManager.createOrEditArtwork(artistName: artistName,
                                              artworkName: artworkName,
                                              artworkData: editedArtworkData,
                                              nonEmptyURLs: nonEmptyURLs, images: images,
                                              deleteImages: manuallyDeletedImages,
                                              isEditing: true,
                                              compressionRatio: compressionRatio) { result in
                if let result = result {
                    statusMessage = result.message
                    // Go back to the portfolio manager menu if successful
                    if result.success == true {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                isLoading = false
            }
        }
    }

    private func handleArtworkNameChanged() {
        images = []
        cameraRollImages = []
        manuallyDeletedImages = []

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

                let imagesTuple = ImageUtils.getImages(artworkName: artwork.name, artworkURLs: artwork.urls)
                images = imagesTuple.images
                minImagesAllowed = imagesTuple.numAssets
            }
        }
    }
}

struct EditArtworkView_Previews: PreviewProvider {
    static let artistManager = ArtistManager.shared

    static var previews: some View {
        EditArtworkView()
            .environmentObject(artistManager)

        EditArtworkView()
            .environmentObject(artistManager)
            .preferredColorScheme(.dark)
    }
}
