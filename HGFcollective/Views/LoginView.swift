//
//  LoginView.swift
//  HGF Collective
//
//  Created by William Dolke on 24/09/2022.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var loginStatusMessage = ""
    @State private var isSecured: Bool = true
    @State private var showInbox: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "person.fill")
                    .font(.system(size: 64))
                    .padding()
                    .foregroundColor(Color.theme.accent)

                Group {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    if isSecured {
                        SecureField("Password", text: $password)
                    } else {
                        TextField("Password", text: $password)
                    }
                }
                .padding(12)
                .background(.gray)
                .cornerRadius(25)

                Button {
                    isSecured.toggle()
                } label: {
                    Image(systemName: self.isSecured ? "eye.slash" : "eye")
                        .foregroundColor(Color.theme.accent)
                        .font(.system(size: 24))
                }

                loginButton

                Text(self.loginStatusMessage)
                    .foregroundColor(.red)
            }
            .padding()

        }
        .navigationTitle("Log In")
    }

    private var loginButton: some View {
        NavigationLink(destination: InboxView().environmentObject(UserManager()).navigationBarBackButtonHidden(true),
                       isActive: $showInbox) {
            Button {
                loginUser()
            } label: {
                HStack {
                    Spacer()
                    Text("Log In")
                        .padding(.vertical, 12)
                        .font(.system(size: 20, weight: .semibold))
                    Image(systemName: "lock.fill")
                        .font(.system(size: 22))
                    Spacer()
                }
                .background(Color.theme.accent)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }

    private func loginUser() {
        print("Logging into Firebase with existing credentials")
        Auth.auth().signIn(withEmail: self.email, password: self.password) { result, error in
            if let error = error {
                print("Failed to login user:", error)
                self.loginStatusMessage = "Failed to login user: \(error)"
                return
            }

            print("Successfully logged in as user: \(result?.user.uid ?? "")")
            self.showInbox = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()

        LoginView()
            .preferredColorScheme(.dark)
    }
}
