//
//  CustomListRow.swift
//  HGFcollective
//
//  Created by William Dolke on 21/01/2023.
//

import SwiftUI

struct CustomListRow: View {
    var assetName: String
    var url: String?
    var text: String

    var body: some View {
        VStack {
            HStack(spacing: 16) {
                ImageBubble(assetName: assetName,
                            url: url,
                            height: 64,
                            width: 64)

                VStack(alignment: .leading) {
                    Text(text)
                        .foregroundColor(Color.theme.systemBackgroundInvert)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

struct CustomListRow_Previews: PreviewProvider {
    static var previews: some View {
        CustomListRow(assetName: "", text: "Artist")

        CustomListRow(assetName: "", text: "Artist")
            .preferredColorScheme(.dark)
    }
}
