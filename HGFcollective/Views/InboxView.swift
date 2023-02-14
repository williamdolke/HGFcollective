//
//  InboxView.swift
//  HGF Collective
//
//  Created by William Dolke on 25/09/2022.
//

import SwiftUI
import FirebaseAuth
import FirebaseAnalytics
import FirebaseCrashlytics

struct InboxView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject var userManager: UserManager

    @State private var showLogOutOptions: Bool = false

    var body: some View {
        VStack {
            conversationTitleRow
            conversationRows
        }
        .navigationBarHidden(true)
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "\(InboxView.self)",
                                           AnalyticsParameterScreenClass: "\(InboxView.self)"])
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
                logger.info("User tapped the settings button")
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 28, weight: .bold))
            }
        }
        .foregroundColor(Color.theme.navigationBarAccent)
        .padding()
        .actionSheet(isPresented: $showLogOutOptions) {
            .init(title: Text("Sign out?"), buttons: [
                .destructive(Text("Yes"), action: {
                    logger.info("User tapped the Yes button")
                    // Sign out of the admin account
                    signOutUser()

                    // Create a new anonymous user so that chat will work
                    // again as a customer
                    signInAnonymously()

                    dismiss()
                }),
                .cancel(Text("Cancel"), action: {
                    logger.info("User tapped 'Cancel' button")
                })
            ])
        }
        .background(Color.theme.accent)
    }

    private var conversationRows: some View {
        ScrollView {
            ForEach(userManager.users) { user in
                let messagesManager = MessagesManager(uid: user.id, isCustomer: false)
                NavigationLink(destination: AdminChatView().environmentObject(messagesManager)) {
                    ConversationPreviewRow(user: user)
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            // swiftlint:disable force_cast
                            // Set messages as read when the admin taps on the chat
                            let unread = (user.read == false)
                            let notSender = (user.sender != UserDefaults.standard.object(forKey: "uid") as! String)
                            if (unread && notSender) {
                                messagesManager.setAsRead()
                            }
                            // swiftlint:enable force_cast
                        })
                .navigationTitle("Inbox")
            }
        }
    }

    /// Sign the admin out
    private func signOutUser() {
        logger.info("Logging out of Firebase with existing credentials.")
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.setValue(nil, forKey: "isAdmin")
            UserDefaults.standard.setValue(nil, forKey: "uid")
        } catch let signOutError as NSError {
            Crashlytics.crashlytics().record(error: signOutError)
            logger.error("Error signing out: \(signOutError)")
        }
        logger.info("Successfully logged out.")
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView()
            .environmentObject(UserManager())

        InboxView()
            .environmentObject(UserManager())
            .preferredColorScheme(.dark)
    }
}
