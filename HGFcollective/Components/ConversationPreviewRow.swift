//
//  ConversationPreviewRow.swift
//  HGF Collective
//
//  Created by William Dolke on 25/09/2022.
//

import SwiftUI

struct ConversationPreviewRow: View {
    var user: User
    var displayName: String

    init(user: User) {
        self.user = user

        if let preferredName = user.preferredName {
            displayName = preferredName.count > 18 ? preferredName.prefix(15) + "..." : preferredName
        } else {
            displayName = user.id.prefix(12) + "..."
        }
    }

    var body: some View {
        VStack {
            HStack(spacing: 16) {
                let notSender = (user.sender != UserDefaults.standard.object(forKey: "uid") as? String)
                let latestMessageUnread = (notSender && !user.read)
                // Show a closed envelope if we have messages to read and an open envelope otherwise
                Image(systemName: latestMessageUnread ? "envelope.fill" : "envelope.open.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color.theme.systemBackgroundInvert)
                    .padding(8)
                    .overlay(RoundedRectangle(cornerRadius: 32)
                        .stroke(lineWidth: 2)
                        .foregroundColor(Color.theme.systemBackgroundInvert)
                    )

                VStack(alignment: .leading) {
                    Text(displayName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.theme.systemBackgroundInvert)
                    Text(user.messagePreview.prefix(18) + "...")
                        .font(.system(size: 16))
                        .foregroundColor(Color.theme.accentSecondary)
                }
                Spacer()

                Text(user.latestTimestamp.formattedDateString(format: "E, d MMM HH:mm:ss"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.theme.accentSecondary)
            }
            Divider()
                .background(Color.theme.accentSecondary)
                .padding(.vertical, 8)
        }
        .padding(.horizontal)
    }
}

struct ConversationPreviewRow_Previews: PreviewProvider {
    static var user = User(id: UUID().uuidString,
                           preferredName: "John Doe",
                           messagePreview: "This Is A Message Preview",
                           latestTimestamp: Date.now,
                           read: false,
                           sender: UUID().uuidString)

    static var previews: some View {
        ConversationPreviewRow(user: user)

        ConversationPreviewRow(user: user)
            .preferredColorScheme(.dark)
    }
}
