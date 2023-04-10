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
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseMessaging
import UserNotifications
import FirebaseCrashlytics

// Configure a logger that can be used globally
let logger = Logger(label: "")

@main
struct HGFcollectiveApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    var body: some Scene {
        WindowGroup {
            LaunchScreen()
            // Start fetching the artists from the database when the launch screen
            // is created. Hopefully by the time the launch screen is dismissed
            // this will have completed.
                .environmentObject(ArtistManager())
                .environmentObject(appDelegate.tabBarState)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    // Create an instance of our Firestore database
    var firestoreDB: Firestore?
    let gcmMessageIDKey = "gcm.message_id"
    var tabBarState = TabBarState()

    // If the app wasn’t running and the user launches it by tapping a push notification,
    // iOS passes the notification to the app in the launchOptions
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        firestoreDB = Firestore.firestore()

        // Authenticate with Firestore
        signInAnonymously()

        // Implement the Firebase Cloud Messaging delegate protocol to receive registration tokens
        Messaging.messaging().delegate = self

        // Register for remote notifications sent via APNs. This shows a permission dialog on first
        // launch. To show the dialog at a more appropriate time move this registration accordingly.
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })

        application.registerForRemoteNotifications()

        return true
    }

    // If the app was running in the foreground or the background, the system notifies the app by
    // calling this method. When the user opens the app by tapping the push notification, iOS may
    // call this method again, so you can update the UI and display relevant information.
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension AppDelegate: MessagingDelegate {
    // This callback is fired at each app startup and whenever a new token is generated
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        logger.info("FCM token retrieved.")

        storeFCMtoken(token: fcmToken)
    }

    /// Store FCM token in the Firestore database
    private func storeFCMtoken(token: String?) {
        // We need to know the customer's/admin's id in order to store the FCM token in the database.
        // However, if we don't know it yet e.g. on the first launch of the app we may receive the FCM
        // token before the Firebase UID. To handle this, wait for a small period of time and attempt
        // to store the FCM token again.
        if let uid = UserDefaults.standard.value(forKey: "uid") as? String, let token = token {
            if (UserDefaults.standard.value(forKey: "isAdmin") != nil) {
                // Upload to the admin collection
                let documentData: [String: [String: String]] = ["token": [uid: token]]

                firestoreDB?.collection("admin").document("fcmToken")
                    .setData(documentData, merge: true) { error in
                        if let error = error {
                            Crashlytics.crashlytics().record(error: error)
                            logger.error("Error sending admin FCM token to Firestore: \(error)")
                        } else {
                            logger.info("Successfully sent admin FCM token to database.")
                        }
                    }
            } else {
                // Upload to the users collection
                let documentData: [String: String] = ["fcmToken": token]

                firestoreDB?.collection("users").document(uid)
                    .setData(documentData, merge: true) { error in
                        if let error = error {
                            Crashlytics.crashlytics().record(error: error)
                            logger.error("Error sending FCM token to Firestore: \(error)")
                        } else {
                            logger.info("Successfully sent FCM token to database.")
                        }
                    }
            }
        } else {
            // Wait for a second before trying to store the FCM token again, hopefully we will
            // know our uid by then.
            let delayInSeconds = 1.0
            logger.error("Could not retrieve uid, waiting for \(delayInSeconds) to retry.")
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                self.storeFCMtoken(token: token)
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications
    // swiftlint:disable line_length
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // swiftlint:enable line_length
        let userInfo = notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)

        completionHandler([[.banner, .badge, .sound]])
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        logger.info("APNs token retrieved.")

        // With swizzling disabled you must set the APNs token here
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logger.error("Unable to register for remote notifications: \(error)")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)

        logger.info("Switching to the chat tab after the user tapped a message notification.")
        tabBarState.selection = 3

        completionHandler()
    }

    func clearNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}

func signInAnonymously() {
    if UserDefaults.standard.string(forKey: "uid") == nil {
        // Sign the user in to Firestore anonymously
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                logger.error("Error signing into database: \(error)")
            } else {
                Analytics.logEvent(AnalyticsEventLogin, parameters: [AnalyticsParameterMethod: "Anonymous"])
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
}
