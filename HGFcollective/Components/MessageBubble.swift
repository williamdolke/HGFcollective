//
//  MessageBubble.swift
//  HGF Collective
//
//  Created by William Dolke on 12/09/2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct MessageBubble: View {
    @State private var showTime = false

    var message: Message
    var isCustomer: Bool

    var body: some View {
        // Messages are green and aligned to the right if they were sent from the local client,
        // or sent by an admin if the user is signed in as admin
        VStack(alignment: isCustomer ? .trailing: .leading) {
            HStack {
                if (message.type == "text") {
                    // Display the message as text if it was typed by the sender
                    Text(message.content)
                        .padding()
                        .background(isCustomer ? Color.theme.accent: Color.theme.accentSecondary)
                        .cornerRadius(30)
                } else if (message.type == "image") {
                    // The content of the message is a url if an image was sent. The
                    // url leads to the image which is stored in Firebase Storage
                    NavigationLink(destination: ImageView(url: message.content)
                        .navigationBarBackButtonHidden(true)) {
                        WebImage(url: URL(string: message.content))
                            .resizable()
                            .placeholder {
                                ProgressView()
                            }
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(30)
                            .frame(width: 200)
                    }
                }
            }
            .frame(maxWidth: 300, alignment: isCustomer ? .trailing: .leading)
            .onTapGesture {
                showTime.toggle()
                logger.info("User tapped on a message bubble")
            }

            // Show the timestamp that the message was sent beneath the message
            // for type="text" messages if the user has tapped on the message
            if showTime {
                Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
                    .font(.caption2)
                    .foregroundColor(Color.theme.accentSecondary)
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
                                 type: "text",
                                 read: false)

    static let image = Message(id: "12345",
                               content:
                               """
                               https://firebasestorage.googleapis.com/v0/b/artapp-28386.appspot
                               .com/o/test.png?alt=media&token=d9d3e8d3-724d-4233-9636-3382cd276749
                               """,
                               isCustomer: true,
                               timestamp: Date(),
                               type: "image",
                               read: false)

    static var previews: some View {
        MessageBubble(message: message, isCustomer: message.isCustomer)

        MessageBubble(message: image, isCustomer: message.isCustomer)
    }
}
