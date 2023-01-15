//
//  LoginView.swift
//  HGF Collective
//
//  Created by William Dolke on 24/09/2022.
//

import SwiftUI
import FirebaseAuth
import FirebaseAnalytics
import FirebaseCrashlytics

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var loginStatusMessage = ""
    @State private var isSecured: Bool = true
    @State private var showInbox: Bool = false

    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            Image("IconSquare")
                .resizable()
                .frame(width: 150, height: 150)

            textFields
            hiddenButton
            loginButton

            Text(self.loginStatusMessage)
                .foregroundColor(Color.theme.favourite)
        }
        .padding()
        .navigationTitle("Log In")
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "\(LoginView.self)",
                                           AnalyticsParameterScreenClass: "\(LoginView.self)"])
        }
    }

    private var textFields: some View {
        Group {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .accentColor(Color.theme.systemBackgroundInvert)
                // Allows the user to tap anywhere, including
                // the padded area, to focus the text field
                .focused($isEmailFocused)
                .onTapGesture {
                    isEmailFocused = true
                }
            if isSecured {
                SecureField("Password", text: $password)
                    .accentColor(Color.theme.systemBackgroundInvert)
                    .focused($isPasswordFocused)
                    .onTapGesture {
                        isPasswordFocused = true
                    }
            } else {
                TextField("Password", text: $password)
                    .accentColor(Color.theme.systemBackgroundInvert)
                    .focused($isPasswordFocused)
                    .onTapGesture {
                        isPasswordFocused = true
                    }
            }
        }
        .padding()
        .background(Color.theme.bubble)
        .cornerRadius(25)
    }

    // Show the password when the user taps this button
    private var hiddenButton: some View {
        Button {
            isSecured.toggle()
            logger.info("User toggled the password visability")
        } label: {
            Image(systemName: self.isSecured ? "eye.slash" : "eye")
                .foregroundColor(Color.theme.accent)
                .font(.system(size: 24))
        }
    }

    private var loginButton: some View {
        // Create the UserManager and consequently fetch all messages with users when the admin successfully logs in
        NavigationLink(destination: InboxView().environmentObject(UserManager()).navigationBarBackButtonHidden(true),
                       isActive: $showInbox) {
            Button {
                // Attempt to sign in as admin
                logger.info("User tapped the login button")
                signInUser()
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
                .foregroundColor(Color.theme.buttonForeground)
                .cornerRadius(10)
            }
        }
    }

    private func signInUser() {
        logger.info("Logging into Firebase with existing credentials.")
        Auth.auth().signIn(withEmail: self.email, password: self.password) { result, error in
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                logger.error("Failed to login user: \(error)")
                self.loginStatusMessage = "Failed to login user: \(error)"
                return
            }

            logger.info("Successfully logged in as user: \(result?.user.uid ?? "nil")")
            UserDefaults.standard.setValue(true, forKey: "isAdmin")
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
