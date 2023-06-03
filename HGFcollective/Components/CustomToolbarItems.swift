//
//  CustomToolbarItems.swift
//  HGFcollective
//
//  Created by William Dolke on 02/06/2023.
//

import SwiftUI

struct CustomToolbarItems: ToolbarContent {
    @AppStorage("isAdmin") var isAdmin: Bool = false
    @Binding var showView: Bool

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Image("IconCircle")
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
        }
        if isAdmin {
            // Create a toolbar item that is transparent and does nothing.
            // Without this the logo will be off center when there is a
            // trailing toolbar item.
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(Color.clear)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    logger.info("User tapped the plus button.")
                    showView = true
                } label: {
                    Image(systemName: "plus")
                        .imageScale(.large)
                }
            }
        }
    }
}

struct CustomToolbarItems_Previews: PreviewProvider {
    static let artistManager = ArtistManager()
    static let appDelegate = AppDelegate()

    static var previews: some View {
        ContentView()
            .environmentObject(artistManager)
            .environmentObject(appDelegate.tabBarState)

        ContentView()
            .environmentObject(artistManager)
            .environmentObject(appDelegate.tabBarState)
            .preferredColorScheme(.dark)
    }
}
