//
//  HGFcollectiveApp.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import SwiftUI
import Logging
import Firebase
import FirebaseMessaging
import UserNotifications

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
    let gcmMessageIDKey = "gcm.message_id"
    var tabBarState = TabBarState()

    // If the app wasn’t running and the user launches it by tapping a push notification,
    // iOS passes the notification to the app in the launchOptions
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        // Use Firebase library to configure APIs
        FirebaseApp.configure()

        // Authenticate with Firestore
        LoginUtils.signInAnonymously()

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

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension AppDelegate: MessagingDelegate {
    // This callback is fired at each app startup and whenever a new token is generated
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        logger.info("FCM token retrieved.")

        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
        LoginUtils.storeFCMtoken(token: fcmToken)
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
}
