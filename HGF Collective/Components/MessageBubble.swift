//
//  MessageBubble.swift
//  HGF Collective
//
//  Created by William Dolke on 12/09/2022.
//

import SwiftUI

struct MessageBubble: View {
    @State private var showTime = false

    var message: Message
    var isCustomer: Bool

    var body: some View {
        VStack(alignment: isCustomer ? .trailing: .leading) {
            HStack {
                Text(message.content)
                    .padding()
                    .background(isCustomer ? Color.theme.accent: .gray)
                    .cornerRadius(30)
            }
            .frame(maxWidth: 300, alignment: isCustomer ? .trailing: .leading)
            .onTapGesture {
                showTime.toggle()
            }

            if showTime {
                Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(isCustomer ? .trailing: .leading, 25)
            }
        }
        .frame(maxWidth: .infinity, alignment: isCustomer ? .trailing: .leading)
        .padding(isCustomer ? .leading : .trailing)
        .padding(.horizontal, 10)
    }
}

struct MessageBubble_Previews: PreviewProvider {
    static let message = Message(id: "12345",
                                 content: "I've been coding applications from scratch in SwiftUI and it's so much fun!",
                                 isCustomer: true,
                                 timestamp: Date(),
                                 type: "text")

    static var previews: some View {
        MessageBubble(message: message, isCustomer: message.isCustomer)
    }
}
