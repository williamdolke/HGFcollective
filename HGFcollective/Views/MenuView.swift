//
//  MenuView.swift
//  HGFcollective
//
//  Created by William Dolke on 25/12/2022.
//

import SwiftUI
import FirebaseAnalytics

struct MenuView: View {
    var body: some View {
        NavigationView {
            Form {
                generalSection
                legalSection
            }
            .navigationTitle("Menu")
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "\(MenuView.self)",
                                               AnalyticsParameterScreenClass: "\(MenuView.self)"])
            }
        }
    }

    private var generalSection: some View {
        Section {
            NavigationLink(destination: AboutView()) {
                Text("About")
            }
            NavigationLink(destination: ReportView()) {
                Text("Report a problem")
            }
        } header: {
            Text("General")
        }
    }

    private var legalSection: some View {
        Section {
            NavigationLink(destination: HTMLView(filePath: "PrivacyPolicy", ofType: "txt")
                .navigationTitle("Privacy Policy")) {
                Text("Privacy Policy")
            }
            .onTapGesture {
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "PrivacyPolicyScreen",
                                               AnalyticsParameterScreenClass: "PrivacyPolicyScreen"])
            }
            NavigationLink(destination: HTMLView(filePath: "TermsAndConditions", ofType: "txt")
                .navigationTitle("Terms and Conditions")) {
                Text("Terms and Conditions")
            }
            .onTapGesture {
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "TermsAndConditionsScreen",
                                               AnalyticsParameterScreenClass: "TermsAndConditionsScreen"])
            }
            NavigationLink(destination: HTMLView(filePath: "EULA", ofType: "txt")
                .navigationTitle("End User License Agreement")) {
                Text("End User License Agreement")
            }
            .onTapGesture {
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "EULAScreen",
                                               AnalyticsParameterScreenClass: "EULAScreen"])
            }
        } header: {
            Text("Legal")
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
