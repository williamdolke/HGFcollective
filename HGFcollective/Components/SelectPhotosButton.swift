//
//  SelectPhotosButton.swift
//  HGFcollective
//
//  Created by William Dolke on 07/12/2023.
//

import SwiftUI

/// Button that opens the user's photo library and allows them to select photos for use in the app
struct SelectPhotosButton: View {
    let action: () -> Void
    var showText: Bool = true

    var body: some View {
        Button {
            logger.info("User tapped the select photos button")
            action()
        } label: {
            HStack {
                if showText {
                    Text("**Select photos**")
                        .font(.title2)
                }
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundColor(Color.theme.buttonForeground)
                    .font(.system(size: 25))
            }
            .padding(10)
            .background(Color.theme.accent)
            .cornerRadius(50)
        }
    }
}

#Preview("Light mode") {
    SelectPhotosButton(action: {})
}

#Preview("Dark mode") {
    SelectPhotosButton(action: {})
        .preferredColorScheme(.dark)
}
