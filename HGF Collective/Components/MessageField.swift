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
    @State private var selectedItem: PhotosPickerItem? = nil

    var body: some View {
        HStack {
            Button {
                showImagePicker.toggle()
            } label: {
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundColor(.white)
                    .font(.system(size: 25))
                    .padding(10)
                    .background(Color.theme.accent)
                    .cornerRadius(50)
            }
            .padding([.top, .bottom], 10)

            // Custom text field created below
            CustomTextField(text: $message, image: $image, placeholder: Text("Enter your message here"))
                .frame(height: 160)
                .contentShape(Rectangle())
                .disableAutocorrection(true)

            NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true), isActive: $showLogin) {
                Button {
                    if message == "admin login" {
                        message = ""
                        self.showLogin = true
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
                        .foregroundColor(.white)
                        .font(.system(size: 25))
                        .padding(10)
                        .background(Color.theme.accent)
                        .cornerRadius(50)
                }
                .padding([.top, .bottom], 10)
            }
        }
        .padding(.horizontal)
        .background(.gray)
        .cornerRadius(50)
        .padding(5)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $image)
            
            // For camera use
            // ImagePicker(sourceType: .camera, selectedImage: self.$image)
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
    
    var placeholder: Text
    var editingChanged: (Bool) -> Void = { _ in }
    var commit: () -> Void = { }

    var body: some View {
        ZStack(alignment: .leading) {
            // If text is empty, show the placeholder on top of the TextField
            if text.isEmpty {
                placeholder
                .opacity(0.5)
            }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
            
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .aspectRatio(contentMode: .fill)
            }
        }
    }
}
