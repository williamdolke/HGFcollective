//
//  MessageField.swift
//  HGF Collective
//
//  Created by William Dolke on 12/09/2022.
//

import SwiftUI
import PhotosUI

@available(iOS 16.0, *)
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
            ImagePickerView(selectedImage: $image, sourceType: .photoLibrary)
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
