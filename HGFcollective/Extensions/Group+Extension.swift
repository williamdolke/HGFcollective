//
//  Group+Extension.swift
//  HGFcollective
//
//  Created by William Dolke on 30/06/2023.
//

import SwiftUI
import UIKit

struct KeyboardDismissGestureView<Content: View>: View {
    let content: Content
    let gesture = DragGesture()

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .gesture(gesture
                .onChanged { value in
                    // Ignore upward swipes
                    guard value.translation.height > 0 else { return }
                }
                .onEnded { _ in
                    UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.endEditing(true)
                }
            )
    }
}

extension View {
    func keyboardDismissGesture() -> some View {
        KeyboardDismissGestureView { self }
    }
}
