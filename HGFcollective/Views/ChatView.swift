//
//  ChatView.swift
//  HGF Collective
//
//  Created by William Dolke on 12/09/2022.
//

import SwiftUI
import FirebaseAnalytics

struct ChatView: View {
    @EnvironmentObject var messagesManager: MessagesManager
    @EnvironmentObject var enquiryManager: EnquiryManager
    @EnvironmentObject var tabBarState: TabBarState

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    ChatTitleRow()
                    chatHistory
                }
                .background(Color.theme.accent)

                MessageField()
                    .environmentObject(messagesManager)
            }
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "\(ChatView.self)",
                                               AnalyticsParameterScreenClass: "\(ChatView.self)"])
            }
        }
        // On iPad, navigationLinks don't work in InboxView without the following
        .navigationViewStyle(StackNavigationViewStyle())
    }

    /// Display all messages that have been sent by the customer and admin(s)
    private var chatHistory: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ForEach(messagesManager.messages, id: \.id) { message in
                    MessageBubble(message: message, isCustomer: message.isCustomer)
                }
            }
            .padding(.top, 10)
            .background(Color.theme.systemBackground)
            .cornerRadius(30, corners: [.topLeft, .topRight])
            // When the view appears, scroll to the bottom of the conversation and handle unread messages
            .onAppear {
                withAnimation {
                    proxy.scrollTo(messagesManager.latestMessageId, anchor: .bottom)
                }
                
                let unread = (messagesManager.user?.read == false)
                let notSender = (messagesManager.user?.sender != UserDefaults.standard.object(forKey: "uid") as? String)

                // Set as read and recalculate the number of unread messages
                // if we're not the sender and it is currently unread
                if (unread && notSender) {
                    messagesManager.setAsRead()
                    messagesManager.countUnreadMessages()
                }
            }
            // Scroll to the bottom of the conversation when a new message is created or received
            .onChange(of: messagesManager.latestMessageId) { id in
                withAnimation {
                    proxy.scrollTo(id, anchor: .bottom)
                }
            }
            // Update the notification badge on the chat tab
            .onChange(of:messagesManager.unreadMessages) { _ in
                logger.info("Setting notification badge on the chat tab to \(messagesManager.unreadMessages).")
                tabBarState.unreadMessages = messagesManager.unreadMessages
            }
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
