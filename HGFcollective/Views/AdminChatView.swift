//
//  AdminChatView.swift
//  HGF Collective
//
//  Created by William Dolke on 25/09/2022.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAnalytics

struct AdminChatView: View {
    @EnvironmentObject var messagesManager: MessagesManager
    @EnvironmentObject var tabBarState: TabBarState

    @State private var showDeleteChatOptions: Bool = false

    var body: some View {
        VStack {
            chatHistory

            MessageField()
                .environmentObject(messagesManager)
        }
        .navigationBarTitleDisplayMode(.inline)
        // Display a trash can which allows admins to delete chats
        .navigationBarItems(trailing: deleteChatButton)
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
                }
            }
            // Scroll to the bottom of the conversation when a new message is created or received
            .onChange(of: messagesManager.latestMessageId) { id in
                withAnimation {
                    proxy.scrollTo(id, anchor: .bottom)
                }
            }
            // Set messages as read when the admin is viewing the chat
            .onChange(of:messagesManager.user?.latestTimestamp) { _ in
                let unread = (messagesManager.user?.read == false)
                let notSender = (messagesManager.user?.sender != UserDefaults.standard.object(forKey: "uid") as? String)

                // Set as read and recalculate the number of unread messages
                // if we're not the sender and it is currently unread
                if (unread && notSender) {
                    messagesManager.setAsRead()
                }
            }
        }
    }

    private var deleteChatButton: some View {
        Button {
            showDeleteChatOptions.toggle()
            logger.info("User tapped the settings button.")
        } label: {
            Image(systemName: "trash")
                .imageScale(.large)
        }
        .actionSheet(isPresented: $showDeleteChatOptions) {
            .init(title: Text("Delete all chat history?"), buttons: [
                .destructive(Text("Yes"), action: {
                    logger.info("User tapped the 'Yes' button.")

                    deleteChat()
                }),
                .cancel(Text("Cancel"), action: {
                    logger.info("User tapped 'Cancel' button.")
                })
            ])
        }
    }

    private func deleteChat() {
        deleteDocumentWithSubcollection(collection: "users", documentId: messagesManager.uid, subCollection: "messages")
    }

    // TODO: Move to extension
    private func deleteDocumentWithSubcollection(collection: String, documentId: String, subCollection: String) {
        let firestoreDB = Firestore.firestore()
        let documentRef = firestoreDB.collection(collection).document(documentId)

        // Delete the document itself
        documentRef.delete { error in
            if let error = error {
                logger.error("Error deleting document: \(error)")
                return
            }

            // Delete all subcollections
            documentRef.collection(subCollection).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else {
                    logger.error("Error retrieving subcollections: \(String(describing: error))")
                    return
                }

                for document in snapshot.documents {
                    document.reference.delete()
                }
            }
        }
    }
}

struct AdminChatView_Previews: PreviewProvider {
    static let messagesManager = MessagesManager(uid: "test", isCustomer: false, notificationName: "test")

    static var previews: some View {
        AdminChatView()
            .environmentObject(messagesManager)

        AdminChatView()
            .environmentObject(messagesManager)
            .preferredColorScheme(.dark)
    }
}
