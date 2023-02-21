//
//  MessageField.swift
//  HGF Collective
//
//  Created by William Dolke on 12/09/2022.
//

import SwiftUI
import PhotosUI

struct MessageField: View {
    @EnvironmentObject var messagesManager: MessagesManager

    @State private var image: UIImage?
    @State private var message = ""
    @State private var showImagePicker = false
    @State private var showLogin: Bool = false
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        HStack {
            Button {
                showImagePicker.toggle()
                logger.info("User tapped the image picker button")
            } label: {
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundColor(Color.theme.buttonForeground)
                    .font(.system(size: 25))
                    .padding(10)
                    .background(Color.theme.accent)
                    .cornerRadius(50)
            }

            CustomTextField(text: $message, image: $image, placeholder: Text("Enter your message here"))
                .padding()
                .contentShape(Rectangle())
                .disableAutocorrection(true)

            sendButton
        }
        .padding(.horizontal)
        .background(Color.theme.bubble)
        .cornerRadius(50)
        .padding(5)
        .sheet(isPresented: $showImagePicker) {
            // For camera, use .camera
            ImagePicker(selectedImage: $image, sourceType: .photoLibrary)
        }
    }

    private var sendButton: some View {
        NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true), isActive: $showLogin) {
            Button {
                if message.lowercased() == "admin login" {
                    message = ""
                    self.showLogin = true
                    logger.info("User entered the secret keyphrase")
                } else if message != "" {
                    messagesManager.sendMessage(text: message, type: "text")
                    message = ""
                }

                if image != nil {
                    messagesManager.sendImage(image: image!)
                    image = nil
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(Color.theme.buttonForeground)
                    .font(.system(size: 25))
                    .padding(10)
                    .background(Color.theme.accent)
                    .cornerRadius(50)
            }
            .padding([.top, .bottom], 10)
        }
    }
}

struct MessageField_Previews: PreviewProvider {
    static var previews: some View {
        MessageField()
            .environmentObject(MessagesManager(uid: "test"))

        MessageField()
            .environmentObject(MessagesManager(uid: "test"))
            .preferredColorScheme(.dark)
    }
}

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
