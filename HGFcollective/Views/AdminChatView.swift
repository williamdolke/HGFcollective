//
//  AdminChatView.swift
//  HGF Collective
//
//  Created by William Dolke on 25/09/2022.
//

import SwiftUI
import FirebaseAnalytics

struct AdminChatView: View {
    @EnvironmentObject var messagesManager: MessagesManager

    var body: some View {
        VStack {
            chatHistory

            MessageField()
                .environmentObject(messagesManager)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "\(AdminChatView.self)",
                                           AnalyticsParameterScreenClass: "\(AdminChatView.self)"])
        }
    }

    /// Display all messages that have been sent by the customer and admin(s)
    private var chatHistory: some View {
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
            .onChange(of:messagesManager.user?.latestTimestamp) { _ in
                // swiftlint:disable force_cast
                // Set messages as read when the admin is viewing the chat
                let unread = (messagesManager.user?.read == false)
                let notSender = (messagesManager.uid != UserDefaults.standard.object(forKey: "uid") as! String)
                if (unread && notSender) {
                    messagesManager.setAsRead()
                }
                // swiftlint:enable force_cast
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
