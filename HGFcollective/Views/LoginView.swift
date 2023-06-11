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
    enum LoginField: Hashable {
        case email
        case password
    }

    @EnvironmentObject var messagesManager: MessagesManager

    @State private var email = ""
    @State private var password = ""
    @State private var loginStatusMessage = ""
    @State private var isSecured: Bool = true
    @State private var showInbox: Bool = false

    @FocusState private var fieldInFocus: LoginField?

    var body: some View {
        VStack(spacing: 16) {
            Image("IconSquare")
                .resizable()
                .frame(width: 150, height: 150)

            textFields

            hiddenButton

            loginButton

            // Show the error message if the login fails
            Text(loginStatusMessage)
                .foregroundColor(Color.theme.favourite)
        }
        .padding()
        .navigationTitle("Log In")
        .onAppear {
            logger.info("Presenting login view.")

            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "\(LoginView.self)",
                                           AnalyticsParameterScreenClass: "\(LoginView.self)"])
        }
    }

    /// Text fields for the user to enter their email and password
    private var textFields: some View {
        Group {
            CustomTextField(title: "Email", text: $email, focusedField: $fieldInFocus, field: .email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            if isSecured {
                // Hide the password from the user
                SecureField("Password", text: $password)
                    .accentColor(Color.theme.systemBackgroundInvert)
                    .focused($fieldInFocus, equals: .password)
            } else {
                // Show the password on screen
                TextField("Password", text: $password)
                    .accentColor(Color.theme.systemBackgroundInvert)
                    .focused($fieldInFocus, equals: .password)
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
                logger.info("User tapped the login button")

                // We don't need to sign the anonymous user out before we log in as they do not have
                // an account and so there is nothing to sign out of

                // Attempt to sign in as admin
                signAdminIn()
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

    /// Attempt to sign the user in with email and password. An error message is presented if the attempt fails.
    private func signAdminIn() {
        logger.info("Logging into Firebase with existing credentials.")
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                logger.error("Log in failed: \(error)")
                loginStatusMessage = "Log in failed: \(error)"

                Crashlytics.crashlytics().record(error: error)
                return
            }

            // Login was successful so clean up after the anonymous user
            LoginUtils.deleteFCMtoken()
            messagesManager.cleanup()

            UserDefaults.standard.setValue(true, forKey: "isAdmin")
            UserDefaults.standard.set(result!.user.uid, forKey: "uid")

            // The FCM token may not have changed so we need to store it
            // as this won't be done by the app delegate
            if let fcmToken = UserDefaults.standard.value(forKey: "fcmToken") as? String {
                LoginUtils.storeFCMtoken(token: fcmToken)
            }

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
