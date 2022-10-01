//
//  HomeView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var artistManager: ArtistManager
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    Text("Discover")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    GeometryReader { geo in
                        ScrollView(.horizontal) {
                            HStack(spacing: geo.size.width*0.04) {
                                ForEach(0..<artistManager.numDiscoverArtworks) {_ in
                                    Button {
                                        // action
                                    } label: {
                                        ImageBubbleTall()
                                            .frame(width: geo.size.width * 0.48, height: geo.size.height)
                                            .cornerRadius(geo.size.width * 0.3)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Text("Featured Artist - \(artistManager.artists[artistManager.featuredArtistIndex].name)")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    GeometryReader { geo in
                        ScrollView(.horizontal) {
                            HStack(spacing: geo.size.width * 0.04) {
                                ForEach(0..<(artistManager.artists[artistManager.featuredArtistIndex].artworks?.count ?? 1)) {_ in
                                    Button {
                                        // action
                                    } label: {
                                        ImageBubbleWide()
                                            .frame(width: geo.size.width, height: geo.size.height)
                                            .cornerRadius(geo.size.width * 0.15)
                                    }
                                }
                            }
                        }
                    }
                    .padding([.horizontal, .bottom])
                    
                    Spacer()
                    
                }
                .navigationTitle("Home")
                .navigationBarItems(trailing:
                                        Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .padding(.top, 90))
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
        
        HomeView()
            .preferredColorScheme(.dark)
    }
}
