//
//  SnapCarousel.swift
//  HGFcollective
//
//  Created by William Dolke on 13/12/2022.
//

import SwiftUI

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
         sensitivity: CGFloat = 1.8,
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
            // One sided snap carousel
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
                    .onEnded({value in
                        let translationX = value.translation.width

                        // Convert the translation into progress (0 - 1 - 2 - etc.) and round the
                        // value based on the progress increasing or decreasing the currentIndex
                        let progress = -sensitivity * translationX / width
                        let roundIndex = progress.rounded()

                        currentIndex = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)

                        currentIndex = index
                        
                        logger.info("User swiped snap carousel to index \(currentIndex)")
                    })
                    .onChanged({ value in
                        let translationX = value.translation.width

                        // Convert the translation into progress (0 - 1 - 2 - etc.) and round the
                        // value based on the progress increasing or decreasing the currentIndex
                        let progress = -sensitivity * translationX / width
                        let roundIndex = progress.rounded()

                        index = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                    })
            )
        }
        .animation(.easeInOut, value: horizontalOffset == 0)
    }
}

struct SnapCarousel_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
