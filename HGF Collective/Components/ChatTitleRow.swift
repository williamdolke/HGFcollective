//
//  ChatTitleRow.swift
//  HGF Collective
//
//  Created by William Dolke on 12/09/2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatTitleRow: View {
    @State var username: String
    @State var iconURL: String
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                WebImage(url: URL(string: iconURL))
                    .resizable()
                    .placeholder(Image(systemName: "person.fill"))
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .cornerRadius(50)
                
                Text(username)
                    .font(.title).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
    }
}

struct ChatTitleRow_Previews: PreviewProvider {
    static var previews: some View {
        ChatTitleRow(username: "HGF Collective Team", iconURL: "")
        
        ChatTitleRow(username: "HGF Collective Team", iconURL: "")
            .preferredColorScheme(.dark)
    }
}
