//
//  ImageBubbleWide.swift
//  HGF Collective
//
//  Created by William Dolke on 18/09/2022.
//

import SwiftUI

struct ImageBubbleWide: View {
    var imageURL = "https://d7hftxdivxxvm.cloudfront.net/?resize_to=fit&width=800&height=800&quality=80&src=https%3A%2F%2Fd32dm0rphc51dk.cloudfront.net%2Fp0hK-VVvk0WQVXlfweVzLw%2Fnormalized.jpg"

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: imageURL)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 400, height: 300)
                    .frame(width: 400, height: 300)
            } placeholder: {
                ProgressView()
            }
        }
    }
}

struct ImageBubbleWide_Previews: PreviewProvider {
    static var previews: some View {
        ImageBubbleWide()
    }
}
