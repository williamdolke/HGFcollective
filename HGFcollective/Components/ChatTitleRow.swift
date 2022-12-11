//
//  ChatTitleRow.swift
//  HGF Collective
//
//  Created by William Dolke on 12/09/2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatTitleRow: View {
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Image("IconCircle")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(60)

                let chatName = Bundle.main.object(forInfoDictionaryKey: "Chat name") as? String ?? ""
                Text(chatName)
                    .font(.title).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
    }
}

struct ChatTitleRow_Previews: PreviewProvider {
    static var previews: some View {
        ChatTitleRow()

        ChatTitleRow()
            .preferredColorScheme(.dark)
    }
}
