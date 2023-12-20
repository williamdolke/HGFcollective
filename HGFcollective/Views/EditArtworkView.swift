//
//  EditArtworkView.swift
//  HGFcollective
//
//  Created by William Dolke on 22/06/2023.
//

import SwiftUI
import FirebaseAnalytics
import FirebaseStorage

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

                // Overlay a cross which lets the user delete the picture
                Button {
                    logger.info("User pressed the close button to delete image \(index)")
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
        // Only update the indices if the user presses submit for efficiency.
        for index in 0..<images.count where images[index].index != index {
            images[index].index = index + 1
        }

        // Filter out any empty elements from urls. These correspond
        // to fields where the admin hasn't input anything.
        let nonEmptyURLs = urls.filter { !$0.isEmpty }

        // Require that there is a name defined
        if artworkName.isEmpty || (images.isEmpty && nonEmptyURLs.isEmpty) {
            logger.info("User has not completed all required fields.")
            statusMessage = "Error: All required and must be completed."
        } else {
            // TODO: Move to function
            isLoading = true

            let dispatchGroup = DispatchGroup()

            // Upload images to Storage if required.
            // We don't want to upload images stored in Assets.xcassets
            // that haven't been overriden or images we already have a
            // url for that haven't been overriden.
            for index in 0..<images.count where images[index].changed == true {
                logger.info("Uploading new artwork image from index \(index) to Storage.")

                // Create the path where the image will be stored in storage
                // swiftlint:disable:next line_length
                let storagePath = "artists/" + artistName + "/artworks/" + artworkName + "/" + artworkName + " " + String(index+1)

                // Convert the image to jpeg format and compress
                guard let imageData = images[index].uiImage?.jpegData(compressionQuality: compressionRatio) else { return }

                dispatchGroup.enter() // Notify the group that a task has started

                Storage.storage().uploadData(path: storagePath, data: imageData) { storageURL in
                    if let storageURL = storageURL {
                        // Delete the image from Storage if that's where it is located
                        if let imageToDelete = images[index].url {
                            Storage.storage().deleteFiles(atURLs: [imageToDelete])
                        }
                        images[index].url = storageURL
                    }
                    dispatchGroup.leave() // Notify the group that a task has completed
                }
            }

            dispatchGroup.notify(queue: .main) {
                // Code to execute once all tasks are completed
                logger.info("All images have finished uploading.")

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
                newArtworkData["urls"] = images.map { $0.url }

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
                    isLoading = false
                }
            }
        }
    }

    private func handleArtworkNameChanged() {
        images = []
        cameraRollImages = []

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

                // TODO: Move to shared utils function
                // Check for images of the artwork to display
                for index in 1...Constants.maximumImages {
                    let artworkAssetName = artworkName + " " + String(index)
                    // url is an empty string if the artwork image hasn't been overriden from the database
                    let url = (artwork.urls?.count ?? 0 >= index) ? artwork.urls?[index-1] : ""

                    // Append the image if we have a url or it is found in
                    // Assets.xcassets and isn't already in the array
                    let haveURL = (url != "")
                    let haveAsset = artworkAssetName != "" &&
                                     UIImage(named: artworkAssetName) != nil
                    let image = Asset(assetName: artworkAssetName,
                                      index: index,
                                      url: url)
                    if ((haveURL || haveAsset) &&
                        !images.contains { $0.assetName == image.assetName }) {
                        images.append(image)
                    }
                }
            }
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

struct DropViewDelegate: DropDelegate {
    let destinationItem: Asset
    @Binding var images: [Asset]
    @Binding var draggedItem: Asset?

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        // Swap images
        if let draggedItem {
            let fromIndex = images.firstIndex(of: draggedItem)
            if let fromIndex {
                let toIndex = images.firstIndex(of: destinationItem)
                if let toIndex, fromIndex != toIndex {
                    withAnimation {
                        self.images.move(fromOffsets: IndexSet(integer: fromIndex),
                                         toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex))
                    }
                }
            }
        }
    }
}
