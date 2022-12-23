//
//  ImageBubble.swift
//  HGF Collective
//
//  Created by William Dolke on 18/09/2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageBubble: View {
    let assetName: String
    var url: String?
    let height: CGFloat?
    let width: CGFloat?
    var fill: Bool = false

    var body: some View {
        HStack {
            if (url != nil) {
                WebImage(url: URL(string: url!))
                    .resizable()
                    .placeholder {
                        ProgressView()
                    }
                    .aspectRatio(contentMode: fill ? .fill : .fit)
                    .frame(width: width, height: height)
            } else if (UIImage(named: assetName) != nil) {
                Image(assetName)
                    .resizable()
                    .aspectRatio(contentMode: fill ? .fill : .fit)
                    .frame(width: width, height: height)
            } else {
                Image(systemName: "photo.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
            }
        }
    }
}

struct ImageBubble_Previews: PreviewProvider {
    static var previews: some View {
        ImageBubble(assetName: "Artwork 1",
                    height: 400,
                    width: 300)
    }
}
