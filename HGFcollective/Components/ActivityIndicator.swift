//
//  ActivityIndicator.swift
//  HGFcollective
//
//  Created by William Dolke on 19/12/2023.
//

import Foundation
import SwiftUI

struct ActivityIndicator: View {
    @State private var isAnimating: Bool = false

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<5) { index in
                Group {
                    Circle()
                        .frame(width: geo.size.width / 5, height: geo.size.height / 5)
                        .scaleEffect(calcScale(index: index))
                        .offset(y: calcYOffset(geo))
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .rotationEffect(!self.isAnimating ? .degrees(0) : .degrees(360))
                .animation(
                    Animation
                        .timingCurve(0.5, 0.15 + Double(index) / 5, 0.25, 1, duration: 1.5)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            self.isAnimating = true
        }
    }

    func calcScale(index: Int) -> CGFloat {
        return (!isAnimating ? 1 - CGFloat(Float(index)) / 5 : 0.2 + CGFloat(index) / 5)
    }

    func calcYOffset(_ geometry: GeometryProxy) -> CGFloat {
        return -geometry.size.height / 2
    }
}

#Preview("Light") {
    ActivityIndicator()
        .frame(width: 200, height: 200)
        .foregroundColor(Color.theme.accent)
}

#Preview("Dark") {
    ActivityIndicator()
        .frame(width: 200, height: 200)
        .foregroundColor(Color.theme.accent)
        .preferredColorScheme(.dark)
}
