//
//  CustomTextField.swift
//  HGFcollective
//
//  Created by William Dolke on 06/01/2023.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    @Binding var image: UIImage?

    @FocusState private var isFocused: Bool

    var placeholder: Text
    var editingChanged: (Bool) -> Void = { _ in }
    var commit: () -> Void = { }

    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
                ZStack(alignment: .leading) {
                    // If text is empty, show the placeholder on top of the TextField
                    if text.isEmpty {
                        placeholder
                            .opacity(0.5)
                    }
                    TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
                        .accentColor(Color.theme.systemBackgroundInvert)
                }
                // Allows the user to tap anywhere, including
                // the padded area, to focus the text field
                .focused($isFocused)
                .onTapGesture {
                    isFocused = true
                }

                // Display an image if the user has specified one to send
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .aspectRatio(contentMode: .fill)
                }
            }
        }
    }
}

struct CustomTextField_Previews: PreviewProvider {
    @State static var text = ""
    @State static var image = UIImage(systemName: "photo.artframe")

    static var previews: some View {
        CustomTextField(text: $text, image: $image, placeholder: Text("Enter text here"))
    }
}
