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
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(messagesManager.messages, id: \.id) { message in
                            MessageBubble(message: message, isCustomer: !message.isCustomer)
                        }
                    }
                    .padding(.top, 10)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(30, corners: [.topLeft, .topRight]) // Custom cornerRadius modifier added in Extensions file
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
        .navigationBarTitleDisplayMode(.inline)
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
