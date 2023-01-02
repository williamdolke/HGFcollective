//
//  HGFcollectiveApp.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI
import Logging
import Firebase
import FirebaseAuth
import FirebaseMessaging
import UserNotifications

// Configure a logger that can be used globally
let logger = Logger(label: "")

@main
struct HGFcollectiveApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            LaunchScreen()
                // Start fetching the artists from the database when the launch screen
                // is created. Hopefully by the time the launch screen is dismissed
                // this will have completed.
                .environmentObject(ArtistManager())
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"

    // swiftlint:disable line_length
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // swiftlint:enable line_length
        // Authenticate with Firestore
        if UserDefaults.standard.string(forKey: "uid") == nil {
            // Sign the user in anonymously
            Auth.auth().signInAnonymously { authResult, error in
                if let err = error {
                    logger.error("Error signing into database: \(err.localizedDescription)")
                } else {
                    logger.info("Sucessfully signed in to database anonymously.")
                }
                guard let user = authResult?.user else { return }

                // Store the UID that identifies the user. This will be used to define
                // the file path for chats in Firestore and files in Firebase Storage
                // that are accessible by the user and the admin(s).
                UserDefaults.standard.set(user.uid, forKey: "uid")
                logger.info("Anonymous login UID: \(user.uid)")
            }
        }

        // Implement the messaging delegate protocol to receive registration tokens
        Messaging.messaging().delegate = self

        // Register for remote notifications
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        if let messageID = userInfo[gcmMessageIDKey] {
            logger.info("Message ID: \(messageID)")
        }

        print(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let deviceToken:[String: String] = ["token": fcmToken ?? ""]
        print("Device token: ", deviceToken) // This token can be used for testing notifications on FCM
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    // swiftlint:disable line_length
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // swiftlint:enable line_length
        let userInfo = notification.request.content.userInfo

        if let messageID = userInfo[gcmMessageIDKey] {
          logger.info("Message ID: \(messageID)")
        }

        print(userInfo)

        completionHandler([[.banner, .badge, .sound]])
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let messageID = userInfo[gcmMessageIDKey] {
            logger.info("Message ID from userNotificationCenter didReceive: \(messageID)")
        }

        print(userInfo)

        completionHandler()
    }
}
