//
//  InboxView.swift
//  HGF Collective
//
//  Created by William Dolke on 25/09/2022.
//

import SwiftUI
import FirebaseAnalytics

struct InboxView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject var userManager = UserManager.shared
    // We only need to access messagesManager in this view when signing out of the admin account.
    // This is the messagesManager that is created by ContentView before signing in as an admin.
    @EnvironmentObject var messagesManager: MessagesManager
    @EnvironmentObject var tabBarState: TabBarState

    @State private var showLogOutOptions: Bool = false
    @State private var updateView: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                conversationTitleRow
                conversationRows
            }
            .navigationBarHidden(true)
            .onAppear {
                logger.info("Presenting inbox view.")

                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "\(InboxView.self)",
                                               AnalyticsParameterScreenClass: "\(InboxView.self)"])
            }
        }
    }

    private var conversationTitleRow: some View {
        HStack(spacing: 16) {
            Image("IconCircle")
                .resizable()
                .frame(width: 40, height: 40)
                .cornerRadius(40)

            Text("Administrator")
                .font(.system(size: 24, weight: .bold))

            Spacer()
            Button {
                showLogOutOptions.toggle()
                logger.info("User tapped the settings button.")
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 28, weight: .bold))
            }
        }
        .foregroundColor(Color.theme.navigationBarAccent)
        .padding()
        .actionSheet(isPresented: $showLogOutOptions) {
            .init(title: Text("Sign out?"),
                  buttons: [
                    .destructive(Text("Yes"), action: {
                        logger.info("User tapped the 'Yes' button.")

                        signOutButtonAction()
                        dismiss()
                    }),
                    .cancel(Text("Cancel"), action: {
                        logger.info("User tapped 'Cancel' button.")
                    })
                  ])
        }
        .background(Color.theme.accent)
    }

    private func signOutButtonAction() {
        // TODO: Delete the user document if there are no messages
        // Sign out of the admin account and cleanup
        LoginUtils.signAdminOut()
        UserManager.shared.logout()

        // Create a new anonymous user so that chat will work again as a customer
        let block: () -> Void = {
            // Refresh the properties of messagesManager since we are creating a new anonymous user.
            // We need to add some additional code to signInAnonymously which can be done through a
            // closure block.
            // swiftlint:disable:next force_cast
            messagesManager.refresh(uid: UserDefaults.standard.object(forKey: "uid") as! String)
        }
        LoginUtils.signInAnonymously(closure: block)

        if let fcmToken = UserDefaults.standard.value(forKey: "fcmToken") as? String {
            LoginUtils.storeFCMtoken(token: fcmToken)
        }
    }

    private var conversationRows: some View {
        ScrollView {
            ForEach(userManager.users) { user in
                NavigationLink(destination: AdminChatView().environmentObject(userManager.messagesManagers[user.id]!)) {
                    ConversationPreviewRow(user: user)
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            // Set messages as read when the admin taps on the chat
                            let unread = (user.read == false)

                            if (unread && user.isCustomer) {
                                tabBarState.unreadMessages = userManager.unreadMessages
                                UIApplication.shared.applicationIconBadgeNumber = userManager.unreadMessages
                                userManager.messagesManagers[user.id]!.setAsRead()
                            }
                        })
                .navigationTitle("Inbox")
            }
        }
        // When the number of unread messages associated with an individual messageManager changes
        // we need to recount the total number of unread messages across all messageManagers
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("UnreadMessageCountChanged"))) { _ in
            userManager.countUnreadMessages()
        }
        // swiftlint:disable:next line_length
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("AdminUnreadMessageCountChanged"))) { _ in
            if tabBarState.unreadMessages != userManager.unreadMessages {
                logger.info("Setting the badge count on the chat tab to \(userManager.unreadMessages).")
                tabBarState.unreadMessages = userManager.unreadMessages
                UIApplication.shared.applicationIconBadgeNumber = userManager.unreadMessages
            }
        }
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView()

        InboxView()
            .preferredColorScheme(.dark)
    }
}
