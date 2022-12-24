//
//  ArtworkView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import MessageUI
import SwiftUI

struct ArtworkView: View {
    @EnvironmentObject var artistManager: ArtistManager
    @EnvironmentObject var favourites: Favourites

    // Store images to be shown in the snap carousel
    @State private var images: [Asset] = []
    // Store the current image in the snap carousel
    @State private var currentIndex: Int = 0
    @State private var result: Result<MFMailComposeResult, Error>?
    @State private var enquireClicked = false

    let artwork: Artwork

    var body: some View {
        VStack {
            artworkImages
            imageIndexIndicator
            artworkInfo
                .padding(.horizontal)

            Text("Price: " + (artwork.price ?? "POA"))
                .font(.title2)

            HStack {
                enquireButton
                    .alignmentGuide(.hCentered, computeValue: { $0.width / 2.0 })
                favouriteButton
                    .padding()
            }
            .frame(maxWidth: .infinity, alignment: Alignment(horizontal: .hCentered, vertical: .center))
        }
        .navigationBarTitle(artwork.name, displayMode: .inline)
        .onAppear {
            for index in 1...10 {
                let artworkAssetName = artwork.name + " " + String(index)
                let image = Asset(assetName: artworkAssetName)
                if (UIImage(named: artworkAssetName) != nil && !images.contains { $0.assetName == image.assetName }) {
                    images.append(image)
                }
            }
        }
    }

    /// Display all images of the artwork in a snap carousel
    private var artworkImages: some View {
        GeometryReader { geo in
            SnapCarousel(index: $currentIndex, items: images) { image in
                NavigationLink(destination: ImageView(artworkName: artwork.name, imageNum: String(currentIndex+1))
                    .navigationBarBackButtonHidden(true)) {
                        ImageBubble(assetName: image.assetName,
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

    /// Display all known information about the artwork
    private var artworkInfo: some View {
        artistManager.getArtworkInfo(artwork: artwork)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
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
            MailView(presentation: self.$enquireClicked, result: self.$result)
                .environmentObject(EnquiryManager())
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

extension HorizontalAlignment {
   private enum HCenterAlignment: AlignmentID {
      static func defaultValue(in dimensions: ViewDimensions) -> CGFloat {
         return dimensions[HorizontalAlignment.center]
      }
   }
   static let hCentered = HorizontalAlignment(HCenterAlignment.self)
}
