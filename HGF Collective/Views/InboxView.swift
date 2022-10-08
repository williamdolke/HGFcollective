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

    @State private var userManager = UserManager()
    @State private var showLogOutOptions: Bool = false

    var body: some View {
        VStack {
            conversationTitleRow
            conversationsView
        }
        .navigationBarHidden(true)
    }

    private var conversationTitleRow: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.fill")
                .font(.system(size: 34, weight: .heavy))

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
        .foregroundColor(Color(UIColor.systemBackground))
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

    private var conversationsView: some View {
        ScrollView {
            ForEach(userManager.users) { user in
                NavigationLink(destination: AdminChatView().environmentObject(MessagesManager(uid: user.id, isCustomer: false))) {
                    ConversationPreviewRow(user: user)
                }
                .navigationTitle(user.id)
            }
        }
    }

    private func signOutUser() {
        print("Logging out of Firebase with existing credentials.")
        do {
            try Auth.auth().signOut()
            dismiss()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
        print("Successfully logged out.")
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView()

        InboxView()
            .preferredColorScheme(.dark)
    }
}
