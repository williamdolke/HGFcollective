//
//  AdminChatView.swift
//  HGF Collective
//
//  Created by William Dolke on 25/09/2022.
//

import SwiftUI
import FirebaseAnalytics
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseCrashlytics

/// Similar to the ChatView but with some additional functionality for admins.
struct AdminChatView: View {
    @EnvironmentObject var messagesManager: MessagesManager
    @EnvironmentObject var tabBarState: TabBarState

    @State private var showDeleteChatOptions: Bool = false
    @State private var showAlert = false
    @State private var displayNameInput: String = ""

    var body: some View {
        VStack {
            chatHistory

            MessageField()
                .environmentObject(messagesManager)
        }
        .navigationBarTitleDisplayMode(.inline)
        // Display a trash can which allows admins to delete chats
        .navigationBarItems(trailing: deleteChatButton)
        // Display an alert where the admin can enter a name for the customer.
        // This name will be displayed in place of the customer's uid in any view.
        .navigationBarItems(trailing: enterDisplayNameButton)
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "\(AdminChatView.self)",
                                           AnalyticsParameterScreenClass: "\(AdminChatView.self)"])
        }
        // An alert that allows the admin to set a display name for the user which will be
        // shown in the inboxView instead of the customer's uid. This allows admins to
        // easily identify users as uid's are hard to remember.
        .alert("Enter a display name", isPresented: $showAlert) {
            TextField("Enter name", text: $displayNameInput)
            Button("OK", action: storePreferredName)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enter a name for this customer.\nThis will be shown in place of their unique identifier.")
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
                let sentByCustomer = (messagesManager.user?.isCustomer == true)

                // Set as read and recalculate the number of unread messages
                // if we're not the sender and it is currently unread
                if (unread && sentByCustomer) {
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
                let sentByCustomer = (messagesManager.user?.isCustomer == true)

                // Set as read and recalculate the number of unread messages
                // if we're not the sender and it is currently unread
                if (unread && sentByCustomer) {
                    messagesManager.setAsRead()
                }
            }
        }
    }

    private var enterDisplayNameButton: some View {
        Button {
            showAlert = true
            logger.info("User tapped the enter display name button.")
        } label: {
            Image(systemName: "person.crop.circle.badge.questionmark.fill")
                .imageScale(.large)
        }
    }

    /// Store the preferred name for the customer that the admin has entered.
    /// This is used in place of the customer's uid in UI elements such as in the inboxView as well as in notifications.
    private func storePreferredName() {
        let firestoreDB = Firestore.firestore()

        firestoreDB.collection("users").document(messagesManager.user!.id)
            .setData(["preferredName": displayNameInput], merge: true) { error in
                if let error = error {
                    Crashlytics.crashlytics().record(error: error)
                    logger.error("Error sending preferredName to Firestore: \(error)")
                } else {
                    logger.info("Successfully sent preferredName to database.")
                }
            }
    }

    /// Show options to allow the admin to delete the chat. This includes all images and chat messages sent.
    private var deleteChatButton: some View {
        Button {
            showDeleteChatOptions.toggle()
            logger.info("User tapped the delete button.")
        } label: {
            Image(systemName: "trash")
                .imageScale(.large)
        }
        .actionSheet(isPresented: $showDeleteChatOptions) {
            .init(title: Text("Delete all chat history?"), buttons: [
                .destructive(Text("Yes"), action: {
                    logger.info("User tapped the 'Yes' button.")

                    deleteChatHistory()
                }),
                .cancel(Text("Cancel"), action: {
                    logger.info("User tapped 'Cancel' button.")
                })
            ])
        }
    }

    /// Delete all chat messages and images
    private func deleteChatHistory() {
        // Delete chat images
        logger.info("Deleting chat image history.")
        deleteFolderContentsFromStorage(folder: "users/\(messagesManager.uid)")

        // Delete chat messages
        logger.info("Deleting chat message history.")
        deleteDocumentAndSubcollectionDocumentsFromFirestore(collection: "users",
                                                     documentId: messagesManager.uid,
                                                     subCollection: "messages")
    }

    private func deleteFolderContentsFromStorage(folder: String) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let folderRef = storageRef.child(folder)

        folderRef.deleteFolderContents()
    }

    private func deleteDocumentAndSubcollectionDocumentsFromFirestore(collection: String,
                                                                      documentId: String,
                                                                      subCollection: String) {
        let firestoreDB = Firestore.firestore()
        let documentRef = firestoreDB.collection(collection).document(documentId)

        documentRef.deleteDocumentAndSubcollectionDocuments(collection: collection,
                                                    documentId: documentId,
                                                    subCollection: subCollection)
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
