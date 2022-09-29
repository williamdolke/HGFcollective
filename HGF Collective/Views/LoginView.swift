//
//  LoginView.swift
//  HGF Collective
//
//  Created by William Dolke on 24/09/2022.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var loginStatusMessage = ""
    @State var isSecured: Bool = true
    @State private var showInbox: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Picker(selection: $isLoginMode, label: Text("Login or create account?")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())

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
                    
                    Button(action: {
                        isSecured.toggle()
                    }) {
                        Image(systemName: self.isSecured ? "eye.slash" : "eye")
                            .foregroundColor(Color.theme.accent)
                    }
                    NavigationLink(destination: InboxView().environmentObject(MessagesManager(uid: "test")).navigationBarBackButtonHidden(true), isActive: $showInbox) {
                        Button {
                            handleAction()
                        } label: {
                            HStack {
                                Spacer()
                                Text(isLoginMode ? "Log In" : "Create Account")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .font(.system(size: 14, weight: .semibold))
                                Spacer()
                            }.background(Color.theme.accent)

                        }
                    }
                    
                    Text(self.loginStatusMessage)
                        .foregroundColor(.red)
                }
                .padding()

            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                            .ignoresSafeArea())
        }
    }

    private func handleAction() {
        if isLoginMode {
            print("Logging into Firebase with existing credentials")
            loginUser()
        } else {
            print("Registering a new account")
        }
    }
    
    private func loginUser() {
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
