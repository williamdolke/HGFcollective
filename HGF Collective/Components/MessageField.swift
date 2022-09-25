//
//  MessageField.swift
//  HGF Collective
//
//  Created by William Dolke on 12/09/2022.
//

import SwiftUI

struct MessageField: View {
    @EnvironmentObject var messagesManager: MessagesManager
    @State private var message = ""
    @State var showLogin: Bool = false

    var body: some View {
        HStack {
            // Custom text field created below
            CustomTextField(placeholder: Text("Enter your message here"), text: $message)
                .frame(height: 60)
                .contentShape(Rectangle())
                .disableAutocorrection(true)
            
            NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true), isActive: $showLogin) {
                Button {
                    if message == "admin login" {
                        message = ""
                        self.showLogin = true
                    } else {
                        messagesManager.sendMessage(text: message)
                        message = ""
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.theme.accent)
                        .cornerRadius(50)
                }
            }
        }
        .padding(.horizontal)
        .background(.gray)
        .cornerRadius(50)
        .padding()
    }
}

struct MessageField_Previews: PreviewProvider {
    static var previews: some View {
        MessageField()
            .environmentObject(MessagesManager())
    }
}

struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool)->() = { _ in }
    var commit: ()->() = { }

    var body: some View {
        ZStack(alignment: .leading) {
            // If text is empty, show the placeholder on top of the TextField
            if text.isEmpty {
                placeholder
                .opacity(0.5)
            }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
        }
    }
}
