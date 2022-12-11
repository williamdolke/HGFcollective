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

    @State private var result: Result<MFMailComposeResult, Error>?
    @State private var enquireClicked = false

    let artwork: Artwork

    var body: some View {
        VStack {
            artworkImages

            artworkInfo
                .padding()

            VStack {
                Text("Price: " + (artwork.price ?? "POA"))
                    .font(.title)

                HStack {
                    enquireButton
                    favouriteButton
                }
            }
        }
        .navigationBarTitle(artwork.name, displayMode: .inline)
    }

    private var artworkImages: some View {
        GeometryReader { geo in
            ScrollView(.horizontal) {
                HStack {
                    ForEach((1...10), id: \.self) {
                        let artworkAssetName = artwork.name + " " + String($0)
                        if (UIImage(named: artworkAssetName) != nil) {
                            NavigationLink(destination: ImageView(artwork: artwork, imageNum: String($0))
                                .navigationBarBackButtonHidden(true)) {
                                ImageBubble(assetName: artworkAssetName,
                                            height: geo.size.height,
                                            width: geo.size.width * 0.9)
                                .frame(width: geo.size.width, height: geo.size.height)
                                // Repeat to center the image
                                .frame(width: geo.size.width, height: geo.size.height)
                            }
                        }
                    }
                }
            }
        }
    }

    private var artworkInfo: some View {
        ScrollView {
            artistManager.getArtworkInfo(artwork: artwork)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private var enquireButton: some View {
        Button {
            enquireClicked.toggle()
        } label: {
            HStack {
                Text("**Enquire**")
                    .font(.title)
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
            } else {
                favourites.add(artwork.name)
            }
        } label: {
            Image(systemName: favourites.contains(artwork.name) ? "heart.fill" : "heart")
                .font(.system(size: 50))
                .foregroundColor(Color.theme.favourite)
        }
    }
}

struct ArtworkView_Previews: PreviewProvider {
    static let artistManager = ArtistManager()
    static let favourites = Favourites()

    static var previews: some View {
        ArtworkView(artwork: Artwork(name: "Artwork",
                                     editionNumber: "1",
                                     editionSize: "Original",
                                     material: "Oil paint on canvas",
                                     signed: "Yes",
                                     price: "£1000"))
            .environmentObject(artistManager)
            .environmentObject(favourites)

        ArtworkView(artwork: Artwork(name: "Artwork",
                                     editionNumber: "1",
                                     editionSize: "Original",
                                     material: "Oil paint on canvas",
                                     signed: "Yes"))
            .environmentObject(artistManager)
            .environmentObject(favourites)
            .preferredColorScheme(.dark)
    }
}
