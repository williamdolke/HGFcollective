//
//  ArtistView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI

struct ArtistView: View {
    var artist: Artist

    var body: some View {
        VStack {
            NavigationLink(destination: ImageView().navigationBarBackButtonHidden(true)) {
                GeometryReader { geo in
                    Image(systemName: "person.crop.artframe")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            ScrollView {
                Text(artist.biography)
                    .padding()
            }
        }
        .navigationBarTitle(artist.name, displayMode: .inline)
    }
}

struct ArtistView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistView(artist: Artist(name: "Artist",
                                  biography: """
                                  I am an artist that likes to paint with oil paints.
                                  My favourite thing to paint is the sea!
                                  """))

        ArtistView(artist: Artist(name: "Artist",
                                  biography: """
                                  I am an artist that likes to paint with oil paints.
                                  My favourite thing to paint is the sea!
                                  """))
            .preferredColorScheme(.dark)
    }
}
