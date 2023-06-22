//
//  NotificationSettingsView.swift
//  HGFcollective
//
//  Created by William Dolke on 21/06/2023.
//

import SwiftUI
import FirebaseAnalytics

struct NotificationSettingsView: View {
    @AppStorage("reminderNotificationsEnabled") private var reminderNotificationsEnabled = true

    var body: some View {
        ScrollView {
            VStack {
                Toggle("Reminders", isOn: $reminderNotificationsEnabled)
                    .padding()
                    .onTapGesture {
                        logger.info("User toggled the reminder notification setting to \(reminderNotificationsEnabled)")
                    }

                Spacer()
            }
        }
        .onAppear {
            logger.info("Presenting notification settings view.")

            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "\(NotificationSettingsView.self)",
                                           AnalyticsParameterScreenClass: "\(NotificationSettingsView.self)"])
        }
    }
}

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
    }
}
