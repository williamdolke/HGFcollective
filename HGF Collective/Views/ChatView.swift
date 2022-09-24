//
//  ChatView.swift
//  HGF Collective
//
//  Created by William Dolke on 12/09/2022.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var messagesManager: MessagesManager
    
    var body: some View {
        VStack {
            VStack {
                ChatTitleRow()
                    .environmentObject(messagesManager)
                
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(messagesManager.messages, id: \.id) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding(.top, 10)
                    .background(.white)
                    .cornerRadius(30, corners: [.topLeft, .topRight]) // Custom cornerRadius modifier added in Extensions file
                    .onChange(of: messagesManager.lastMessageId) { id in
                        // When the lastMessageId changes, scroll to the bottom of the conversation
                        withAnimation {
                            proxy.scrollTo(id, anchor: .bottom)
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
    static let messagesManager = MessagesManager()
    
    static var previews: some View {
        ChatView()
            .environmentObject(messagesManager)
    }
}
