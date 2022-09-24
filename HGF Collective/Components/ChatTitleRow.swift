//
//  ChatTitleRow.swift
//  HGF Collective
//
//  Created by William Dolke on 12/09/2022.
//

import SwiftUI

struct ChatTitleRow: View {
    @EnvironmentObject var messagesManager: MessagesManager
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                AsyncImage(url: URL(string: messagesManager.contact.iconURL)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .cornerRadius(50)
                } placeholder: {
                    ProgressView()
                }
                
                Text(messagesManager.contact.name)
                    .font(.title).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Phone logo
                /*Image(systemName: "phone.fill")
                 .foregroundColor(.gray)
                 .padding(10)
                 .background(.white)
                 .cornerRadius(50)*/
            }
            .padding()
        }
    }
}

struct ChatTitleRow_Previews: PreviewProvider {
    static var messagesManager = MessagesManager()
    
    static var previews: some View {
        ChatTitleRow()
            .environmentObject(messagesManager)
    }
}
