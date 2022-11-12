//
//  ConversationPreviewRow.swift
//  HGF Collective
//
//  Created by William Dolke on 25/09/2022.
//

import SwiftUI

struct ConversationPreviewRow: View {
    var user: User

    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Image(systemName: user.unread ? "envelope.fill" : "envelope.open.fill")
                    .font(.system(size: 32))
                    .padding(8)
                    .overlay(RoundedRectangle(cornerRadius: 32)
                        .stroke(lineWidth: 2)
                    )

                VStack(alignment: .leading) {
                    Text(user.id.prefix(12) + "...")
                        .font(.system(size: 20, weight: .bold))
                    Text(user.messagePreview.prefix(18) + "...")
                        .font(.system(size: 16))
                        .foregroundColor(Color(.gray))
                }
                Spacer()

                Text(user.latestTimestamp.formattedDateString(format: "E, d MMM HH:mm:ss"))
                    .font(.system(size: 16, weight: .semibold))
            }
            Divider()
                .background(Color.theme.accent)
                .padding(.vertical, 8)
        }.padding(.horizontal)
    }
}

struct ConversationPreviewRow_Previews: PreviewProvider {
    static var user = User(id: UUID().uuidString,
                           messagePreview: "This Is A Message Preview",
                           latestTimestamp: Date.now,
                           unread: true)

    static var previews: some View {
        ConversationPreviewRow(user: user)

        ConversationPreviewRow(user: user)
            .preferredColorScheme(.dark)
    }
}
