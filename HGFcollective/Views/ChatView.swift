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

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    ChatTitleRow()
                    sentMessages
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
    private var sentMessages: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ForEach(messagesManager.messages, id: \.id) { message in
                    MessageBubble(message: message, isCustomer: message.isCustomer)
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
                // When the view appears, scroll to the bottom of the conversation
                withAnimation {
                    proxy.scrollTo(messagesManager.lastMessageId, anchor: .bottom)
                }
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
