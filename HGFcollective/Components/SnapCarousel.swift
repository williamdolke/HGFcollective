//
//  SnapCarousel.swift
//  HGFcollective
//
//  Created by William Dolke on 13/12/2022.
//

import SwiftUI

/// One sided snap carousel
struct SnapCarousel<Content: View, T: Identifiable>: View {
    @Binding var index: Int
    @State var currentIndex: Int = 0
    @GestureState var horizontalOffset: CGFloat = 0

    let content: (T) -> Content
    let list: [T]
    let spacing: CGFloat
    let trailingSpace: CGFloat
    let sensitivity: CGFloat

    init(spacing: CGFloat = 15,
         trailingSpace: CGFloat = 100,
         sensitivity: CGFloat = 5,
         index: Binding<Int>,
         items: [T],
         @ViewBuilder content: @escaping (T) -> Content) {
        self.list = items
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self.sensitivity = sensitivity
        self._index = index
        self.content = content
    }

    var body: some View {
        GeometryReader { geo in
            let width = (geo.size.width - (trailingSpace - spacing))
            let adjustmentWidth = (trailingSpace / 2) - spacing

            HStack(spacing: spacing) {
                ForEach(list) { item in
                    content(item)
                        .frame(width: geo.size.width - trailingSpace)
                }
            }
            .padding(.horizontal, spacing)
            .offset(x: (CGFloat(currentIndex) * -width) + adjustmentWidth + horizontalOffset)
            .highPriorityGesture(
                DragGesture()
                    .updating($horizontalOffset, body: { value, out, _ in
                        out = value.translation.width
                    })
                    .onEnded({_ in
                        currentIndex = index
                        logger.info("User swiped snap carousel to index \(currentIndex)")
                    })
                    .onChanged({ value in
                        let translationX = value.translation.width

                        // Convert the translation into progress (-1, 0, 1) and round the
                        // value based on the progress increasing or decreasing the currentIndex
                        let progress = -sensitivity * translationX / width
                        // Limit to values -1, 0 and 1
                        let roundIndex = max(-1, min(1, progress.rounded()))

                        // Don't allow scrolling beyond the first and last image
                        index = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                    })
            )
        }
        .animation(.easeInOut, value: horizontalOffset == 0)
    }
}

struct SnapCarousel_Previews: PreviewProvider {
    static let artistManager = ArtistManager()
    static let appDelegate = AppDelegate()

    static var previews: some View {
        ContentView()
            .environmentObject(artistManager)
            .environmentObject(appDelegate.tabBarState)

        ContentView()
            .environmentObject(artistManager)
            .environmentObject(appDelegate.tabBarState)
            .preferredColorScheme(.dark)
    }
}
