//
//  ImageIndexIndicator.swift
//  HGFcollective
//
//  Created by William Dolke on 23/12/2022.
//

import SwiftUI

struct SwiftUIView: View {
    let images: [Asset]
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(images.indices, id: \.self) { index in
                Circle()
                    .fill(Color.theme.accentSecondary.opacity(currentIndex == index ? 1 : 0.1))
                    .frame(width: 8, height: 8)
                    .scaleEffect(currentIndex == index ? 1.4 : 1)
                    .animation(.spring(), value: currentIndex == index)
            }
        }
    }
}
