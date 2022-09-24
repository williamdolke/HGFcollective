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
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var enquireClicked = false
    var artwork: Artwork
    
    var body: some View {
        VStack{
            NavigationLink(destination: ImageView().navigationBarBackButtonHidden(true)) {
                GeometryReader { geo in
                    Image(systemName: "person.crop.artframe")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: geo.size.height)
                        // Repeat to center the image
                        .frame(width: geo.size.width, height: geo.size.height)
                }
            }
                
            ScrollView {
                artistManager.getArtworkInfo(artwork: artwork)
                    .padding(.horizontal, 20)
            }
                
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
                .foregroundColor(.white)
            }
            .contentShape(Rectangle())
            .padding(.bottom, 10)
                
            .sheet(isPresented: $enquireClicked) {
                MailView(presentation: self.$enquireClicked, result: self.$result)
                    .environmentObject(EnquiryManager())
                    .disabled(!MFMailComposeViewController.canSendMail())
            }
        }
        .navigationBarTitle(artwork.name, displayMode: .inline)
    }
}

struct ArtworkView_Previews: PreviewProvider {
    static let artistManager = ArtistManager()
    
    static var previews: some View {
        ArtworkView(artwork: Artwork(name: "Artwork", editionNumber: "1", editionSize: "Original", material: "Oil paint on canvas", signed: "Yes"))
            .environmentObject(artistManager)
    }
}
