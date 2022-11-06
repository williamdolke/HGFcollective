//
//  ChatView.swift
//  HGF Collective
//
//  Created by William Dolke on 12/09/2022.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var messagesManager: MessagesManager
    @EnvironmentObject var enquiryManager: EnquiryManager

    var body: some View {
        VStack {
            VStack {
                ChatTitleRow(username: enquiryManager.chat.name, iconURL: enquiryManager.chat.iconURL)

                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(messagesManager.messages, id: \.id) { message in
                            MessageBubble(message: message, isCustomer: message.isCustomer)
                        }
                    }
                    .padding(.top, 10)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(30, corners: [.topLeft, .topRight]) // Custom cornerRadius modifier
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
            .background(Color.theme.accent)

            MessageField()
                .environmentObject(messagesManager)
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static let messagesManager = MessagesManager(uid: "test")
    static let enquiryManager = EnquiryManager()

    static var previews: some View {
        ChatView()
            .environmentObject(messagesManager)
            .environmentObject(enquiryManager)

        ChatView()
            .environmentObject(messagesManager)
            .environmentObject(enquiryManager)
            .preferredColorScheme(.dark)
    }
}
