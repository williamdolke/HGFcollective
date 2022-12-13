//
//  ContactView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI

struct ContactView: View {
    @EnvironmentObject var messagesManager: MessagesManager

    var body: some View {
        NavigationView {
            ChatView()
                .environmentObject(messagesManager)
                .environmentObject(EnquiryManager())
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .navigationTitle("Contact Us")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image("IconCircle")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                    }
                }
        }
    }
}

struct ContactView_Previews: PreviewProvider {
    static let messagesManager = MessagesManager(uid: "test")

    static var previews: some View {
        ContactView()
            .environmentObject(messagesManager)

        ContactView()
            .environmentObject(messagesManager)
            .preferredColorScheme(.dark)
    }
}
