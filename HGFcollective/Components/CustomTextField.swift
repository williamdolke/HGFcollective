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
                if (image != nil) {
                    Image(uiImage: image!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .overlay(alignment: .topTrailing) {
                            Button {
                                logger.info("User pressed the close button to delete the image from the chat message")
                                image = nil
                            } label: {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .foregroundColor(Color.theme.systemBackgroundInvert)
                                    .background(Color.theme.systemBackground)
                                    .clipShape(Circle())
                                    .padding()
                            }
                            .frame(width: 20, height: 20)
                        }
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
