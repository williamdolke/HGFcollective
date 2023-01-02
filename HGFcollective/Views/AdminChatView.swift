//
//  AdminChatView.swift
//  HGF Collective
//
//  Created by William Dolke on 25/09/2022.
//

import SwiftUI

struct AdminChatView: View {
    @EnvironmentObject var messagesManager: MessagesManager

    var body: some View {
        VStack {
            VStack {
                sentMessages
            }
            .background(Color.theme.accent)

            MessageField()
                .environmentObject(messagesManager)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var sentMessages: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ForEach(messagesManager.messages, id: \.id) { message in
                    MessageBubble(message: message, isCustomer: !message.isCustomer)
                }
            }
            .padding(.top, 10)
            .background(Color.theme.systemBackground)
            .cornerRadius(30, corners: [.topLeft, .topRight])
            .onChange(of: messagesManager.lastMessageId) { id in
                // When the lastMessageId changes, scroll to the bottom of the conversation
                withAnimation {
                    proxy.scrollTo(id, anchor: .bottom)
                }
            }
            .onAppear {
                withAnimation {
                    proxy.scrollTo(messagesManager.lastMessageId, anchor: .bottom)
                }
            }
        }
    }
}

struct AdminChatView_Previews: PreviewProvider {
    static let messagesManager = MessagesManager(uid: "test", isCustomer: false)

    static var previews: some View {
        AdminChatView()
            .environmentObject(messagesManager)

        AdminChatView()
            .environmentObject(messagesManager)
            .preferredColorScheme(.dark)
    }
}
