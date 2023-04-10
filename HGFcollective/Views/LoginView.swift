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

            // Show the error message if the login fails
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

    /// Text fields for the user to enter their email and password
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
                // Hide the password from the user
                SecureField("Password", text: $password)
                    .accentColor(Color.theme.systemBackgroundInvert)
                    .focused($isPasswordFocused)
                    .onTapGesture {
                        isPasswordFocused = true
                    }
            } else {
                // Show the password on screen
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

    /// Show or hide the password when the user taps this button
    private var hiddenButton: some View {
        Button {
            isSecured.toggle()
            logger.info("User toggled the password visability")
        } label: {
            Image(systemName: isSecured ? "eye.slash" : "eye")
                .foregroundColor(Color.theme.accent)
                .font(.system(size: 24))
        }
    }

    /// Button that attempts to sign the user in when tapped
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

    /// Attempt to sign the user in. An error message is presented if the attempt fails.
    private func signInUser() {
        logger.info("Logging into Firebase with existing credentials.")
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                logger.error("Failed to login user: \(error)")
                loginStatusMessage = "Failed to login user: \(error)"

                Crashlytics.crashlytics().record(error: error)
                return
            }

            UserDefaults.standard.setValue(true, forKey: "isAdmin")
            UserDefaults.standard.set(result!.user.uid, forKey: "uid")
            logger.info("Successfully logged in as user: \(result!.user.uid)")

            Analytics.logEvent(AnalyticsEventLogin, parameters: [AnalyticsParameterMethod: "Email"])

            showInbox = true
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
