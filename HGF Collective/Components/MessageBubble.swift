//
//  MessageBubble.swift
//  HGF Collective
//
//  Created by William Dolke on 12/09/2022.
//

import SwiftUI

struct MessageBubble: View {
    var message: Message
    @State private var showTime = false
    
    var body: some View {
        VStack(alignment: message.isCustomer ? .leading : .trailing) {
            HStack {
                Text(message.content)
                    .padding()
                    .background(message.isCustomer ? .gray : Color.theme.accent)
                    .cornerRadius(30)
            }
            .frame(maxWidth: 300, alignment: message.isCustomer ? .leading : .trailing)
            .onTapGesture {
                showTime.toggle()
            }
            
            if showTime {
                Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(message.isCustomer ? .leading : .trailing, 25)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isCustomer ? .leading : .trailing)
        .padding(message.isCustomer ? .leading : .trailing)
        .padding(.horizontal, 10)
    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        MessageBubble(message: Message(id: "12345", content: "I've been coding applications from scratch in SwiftUI and it's so much fun!", isCustomer: true, timestamp: Date(), type: "text"))
    }
}
