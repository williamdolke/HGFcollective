//
//  InboxView.swift
//  HGF Collective
//
//  Created by William Dolke on 25/09/2022.
//

import SwiftUI
import FirebaseAuth

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
    }

    private var conversationTitleRow: some View {
        HStack(spacing: 16) {
            Image("IconCircle")
                .resizable()
                .frame(width: 40, height: 40)
                .cornerRadius(40)

            Text("Admin Account")
                .font(.system(size: 24, weight: .bold))

            Spacer()
            Button {
                showLogOutOptions.toggle()
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 28, weight: .bold))
            }
        }
        .foregroundColor(Color.theme.systemBackground)
        .padding()
        .actionSheet(isPresented: $showLogOutOptions) {
            .init(title: Text("Sign out?"), buttons: [
                .destructive(Text("Yes"), action: {
                    signOutUser()
                }),
                .cancel()
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
                }.simultaneousGesture(TapGesture().onEnded {
                    messagesManager.setAsRead()
                })
                .navigationTitle(user.id)
            }
        }
    }

    private func signOutUser() {
        logger.info("Logging out of Firebase with existing credentials.")
        do {
            try Auth.auth().signOut()
            dismiss()
        } catch let signOutError as NSError {
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
