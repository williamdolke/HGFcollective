//
//  ArtworkView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import MessageUI
import SwiftUI
import FirebaseAnalytics
import FirebaseCrashlytics

struct ArtworkView: View {
    @EnvironmentObject var artistManager: ArtistManager
    @EnvironmentObject var favourites: Favourites

    // Store images to be shown in the snap carousel
    @State private var images: [Asset] = []
    // Store the current image presented in the snap carousel
    @State private var currentIndex: Int = 0
    @State private var result: Result<MFMailComposeResult, Error>?
    @State private var enquireClicked = false

    var artwork: Artwork

    var body: some View {
        // The GeometryReader needs to be defined outside the ScrollView, otherwise it won't
        // take the dimensions of the screen
        GeometryReader { geo in
            ScrollView {
                VStack {
                    SnapCarousel(index: $currentIndex, items: images) { image in
                        let haveURL = artwork.urls?[currentIndex] != ""
                        NavigationLink(destination: ImageView(artworkName: artwork.name,
                                                              imageNum: String(currentIndex+1),
                                                              url: haveURL ? artwork.urls?[currentIndex] : nil)
                            .navigationBarBackButtonHidden(true)) {
                                ImageBubble(assetName: image.assetName,
                                            url: image.url,
                                            height: 0.6 * geo.size.height,
                                            width: nil)
                        }
                    }
                    _VSpacer(minHeight: 0.6 * geo.size.height)

                    imageIndexIndicator

                    if artwork.description != nil {
                        description
                            .padding(.horizontal)
                    }

                    if let artworkInfo = artistManager.getArtworkInfo(artwork: artwork) {
                        artworkInfoSection(artworkInfo: artworkInfo)
                    }

                    Text("Price: " + (artwork.price ?? "POA"))
                        .font(.title2)

                    HStack {
                        enquireButton
                            .alignmentGuide(.horizontalCenterAlignment, computeValue: { $0.width / 2.0 })
                        favouriteButton
                            .padding()
                    }
                    .frame(maxWidth: .infinity,
                           alignment: Alignment(horizontal: .horizontalCenterAlignment, vertical: .center))
                }
            }
        }
        .navigationBarTitle(artwork.name, displayMode: .inline)
        .onAppear {
            // Check for images of the artwork to display
            for index in 1...10 {
                let artworkAssetName = artwork.name + " " + String(index)
                // The URL is an empty string if the artwork image hasn't been overriden from the database
                let url = (artwork.urls?.count ?? 0 >= index) ? artwork.urls?[index-1] : ""

                // Append the image if we have a url or it is found in
                // Assets.xcassets and isn't already in the array
                let haveURL = (url != "")
                let haveAsset = artworkAssetName != "" &&
                                 UIImage(named: artworkAssetName) != nil
                let image = Asset(assetName: artworkAssetName,
                                  index: index,
                                  url: haveURL ? url : nil)
                if ((haveURL || haveAsset) &&
                    !images.contains { $0.assetName == image.assetName }) {
                    images.append(image)
                }
            }

            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "\(artwork.name)",
                                           AnalyticsParameterScreenClass: "\(ArtworkView.self)"])
        }
    }

    /// Display all images of the artwork in a snap carousel
    private var artworkImages: some View {
        GeometryReader { geo in
            SnapCarousel(index: $currentIndex, items: images) { image in
                let haveURL = artwork.urls?[currentIndex] != ""
                NavigationLink(destination: ImageView(artworkName: artwork.name,
                                                      imageNum: String(currentIndex+1),
                                                      url: haveURL ? artwork.urls?[currentIndex] : nil)
                    .navigationBarBackButtonHidden(true)) {
                        ImageBubble(assetName: image.assetName,
                                    url: image.url,
                                    height: geo.size.height,
                                    width: nil)
                }
            }
        }
    }

    /// Indicate which image number is being displayed by the snap carousel
    private var imageIndexIndicator: some View {
        HStack(spacing: 10) {
            ForEach(images.indices, id: \.self) { index in
                Circle()
                    .fill(Color.theme.accentSecondary.opacity(currentIndex == index ? 1 : 0.1))
                    .frame(width: 8, height: 8)
                    .scaleEffect(currentIndex == index ? 1.4 : 1)
                    .animation(.spring(), value: currentIndex == index)
            }
        }
    }

    /// Display a description of the artwork if it exists
    private var description: some View {
        VStack {
            HStack {
                Text("Description")
                    .font(.title2)
                // Align the title to the left
                Spacer()
            }

            Text(artwork.description ?? "")
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    /// Display all known information about the artwork
    private func artworkInfoSection(artworkInfo: Text) -> some View {
        // Only display this section if there is artwork info to display
        VStack {
            HStack {
                Text("Details")
                    .font(.title2)
                // Align the title to the left
                Spacer()
            }

            artworkInfo
                // The padding must come before the background
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .padding(.horizontal)
    }

    private var enquireButton: some View {
        Button {
            enquireClicked.toggle()
            logger.info("User tapped the enquire button")
        } label: {
            HStack {
                Text("**Enquire**")
                    .font(.title2)
                Image(systemName: "envelope")
            }
            .padding()
            .background(Color.theme.accent)
            .cornerRadius(40)
            .foregroundColor(Color.theme.buttonForeground)
        }
        .contentShape(Rectangle())
        .padding(.bottom, 10)
        .sheet(isPresented: $enquireClicked) {
            MailView(presentation: $enquireClicked, result: $result)
                .disabled(!MFMailComposeViewController.canSendMail())
        }
    }

    private var favouriteButton: some View {
        Button {
            if favourites.contains(artwork.name) {
                favourites.remove(artwork.name)
                logger.info("User removed the artwork '\(artwork.name)' from their favourites")
            } else {
                favourites.add(artwork.name)
                logger.info("User added the artwork '\(artwork.name)' from their favourites")
            }
        } label: {
            Image(systemName: favourites.contains(artwork.name) ? "heart.fill" : "heart")
                .font(.system(size: 35))
                .foregroundColor(Color.theme.favourite)
        }
        .scaleEffect(favourites.contains(artwork.name) ? 1.2 : 1)
        .animation(.easeInOut(duration: 1), value: 1)
    }
}

struct ArtworkView_Previews: PreviewProvider {
    // The mail composer can't be presented when the enquire button is pressed as it doesn't
    // work on simulators. Hence, we don't need an EnquiryManager environment object.
    static let artistManager = ArtistManager()
    static let favourites = Favourites()

    static let artwork = Artwork(name: "Artwork",
                                     editionNumber: "1",
                                     editionSize: "Original",
                                     material: "Oil paint on canvas",
                                     signed: "Yes",
                                     price: "£1000")

    static var previews: some View {
        ArtworkView(artwork: artwork)
            .environmentObject(artistManager)
            .environmentObject(favourites)

        ArtworkView(artwork: artwork)
            .environmentObject(artistManager)
            .environmentObject(favourites)
            .preferredColorScheme(.dark)
    }
}
