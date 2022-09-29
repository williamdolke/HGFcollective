//
//  ContactView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI
import FirebaseAuth

struct ContactView: View {
    @EnvironmentObject var messagesManager: MessagesManager
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    Text("")
                    ChatView()
                        .environmentObject(messagesManager)
                        .environmentObject(EnquiryManager())
                        .cornerRadius(30, corners: [.topLeft, .topRight]) // Custom cornerRadius modifier added in Extensions file
                        .navigationTitle("Contact Us")
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
