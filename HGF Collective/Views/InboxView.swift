//
//  InboxView.swift
//  HGF Collective
//
//  Created by William Dolke on 25/09/2022.
//

import SwiftUI

struct InboxView: View {
    @EnvironmentObject var messagesManager: MessagesManager
    @State var showLogOutOptions: Bool = false
    
    var body: some View {
        NavigationView {

            VStack {
                conversationTitleRow
                conversationsView
            }
            .navigationBarHidden(true)
        }.accentColor(.black)
    }

    private var conversationTitleRow: some View {
        HStack(spacing: 16) {

            Image(systemName: "person.fill")
                .font(.system(size: 34, weight: .heavy))

            Text("Admin Account")
                .font(.system(size: 24, weight: .bold))

            Spacer()
            Button {
                showLogOutOptions.toggle()
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 28, weight: .bold))
            }
        }
        .foregroundColor(Color(UIColor.systemBackground))
        .padding()
        .actionSheet(isPresented: $showLogOutOptions) {
            .init(title: Text("Sign out?"), buttons: [
                .destructive(Text("Yes"), action: {
                    print("Handle sign out")
                }),
                    .cancel()
            ])
        }
        .background(Color.theme.accent)
    }

    private var conversationsView: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                NavigationLink(destination: AdminChatView().environmentObject(messagesManager)) {
                    ConversationPreviewRow()
                }
                .navigationBarTitle("")
            }
        }
    }
}

struct InboxView_Previews: PreviewProvider {
    static let messagesManager = MessagesManager()
    
    static var previews: some View {
        InboxView()
            .environmentObject(messagesManager)
        
        InboxView()
            .environmentObject(messagesManager)
            .preferredColorScheme(.dark)
    }
}
