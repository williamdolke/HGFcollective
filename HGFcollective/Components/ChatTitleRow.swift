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
                Image("HGF Circle")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(50)

                Text("HGF Collective Team")
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
