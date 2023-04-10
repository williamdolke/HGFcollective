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
            mediaButton

            CustomTextField(text: $message, image: $image, placeholder: Text("Enter your message here"))
                .padding()
                .contentShape(Rectangle())

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
        // Dismiss the keyboard with a downward drag gesture. The user can also dismiss the
        // keyboard by pressing the 'return' key.
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Ignore upward swipes
                    guard value.translation.height > 0 else { return }
                }
                .onEnded { _ in
                    UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.endEditing(true)
                }
        )
    }

    private var mediaButton: some View {
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
    }

    private var sendButton: some View {
        NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true), isActive: $showLogin) {
            Button {
                if message.lowercased() == "admin login" {
                    message = ""
                    showLogin = true
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
    static let messagesManager = MessagesManager(uid: "test", notificationName: "test")

    static var previews: some View {
        MessageField()
            .environmentObject(messagesManager)

        MessageField()
            .environmentObject(messagesManager)
            .preferredColorScheme(.dark)
    }
}
