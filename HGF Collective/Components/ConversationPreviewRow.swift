//
//  ConversationPreviewRow.swift
//  HGF Collective
//
//  Created by William Dolke on 25/09/2022.
//

import SwiftUI

struct ConversationPreviewRow: View {
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Image(systemName: "person.fill")
                    .font(.system(size: 32))
                    .padding(8)
                    .overlay(RoundedRectangle(cornerRadius: 44)
                                .stroke(Color(.label), lineWidth: 1)
                    )


                VStack(alignment: .leading) {
                    Text("Username")
                        .font(.system(size: 20, weight: .bold))
                    Text("Message preview")
                        .font(.system(size: 16))
                        .foregroundColor(Color(.lightGray))
                }
                Spacer()

                Text("Just now")
                    .font(.system(size: 16, weight: .semibold))
            }
            Divider()
                .padding(.vertical, 8)
        }.padding(.horizontal)
    }
}

struct ConversationPreviewRow_Previews: PreviewProvider {
    static var previews: some View {
        ConversationPreviewRow()
    }
}
