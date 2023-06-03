//
//  MenuView.swift
//  HGFcollective
//
//  Created by William Dolke on 25/12/2022.
//

import SwiftUI
import FirebaseAnalytics

struct MenuView: View {
    @Environment(\.colorScheme) var colorScheme

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
                HStack {
                    Image(systemName: "questionmark.square.fill")
                        .foregroundColor(colorScheme == .dark ? Color.theme.systemBackgroundInvert : Color.theme.accent)
                    Text("About")
                }
            }
            NavigationLink(destination: ReportView()) {
                HStack {
                    Image(systemName: "exclamationmark.bubble.fill")
                        .foregroundColor(colorScheme == .dark ? Color.theme.systemBackgroundInvert : Color.theme.accent)
                    Text("Report a problem")
                }
            }
        } header: {
            Text("General")
        }
    }

    private var legalSection: some View {
        Section {
            NavigationLink(destination: HTMLView(filePath: "PrivacyPolicy", ofType: "txt")
                .navigationTitle("Privacy Policy")) {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                            .foregroundColor(colorScheme == .dark ?
                                             Color.theme.systemBackgroundInvert :
                                                Color.theme.accent)
                        Text("Privacy Policy")
                    }
            }
            NavigationLink(destination: HTMLView(filePath: "TermsAndConditions", ofType: "txt")
                .navigationTitle("Terms and Conditions")) {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                            .foregroundColor(colorScheme == .dark ?
                                             Color.theme.systemBackgroundInvert :
                                                Color.theme.accent)
                        Text("Terms and Conditions")
                    }
            }
            NavigationLink(destination: HTMLView(filePath: "EULA", ofType: "txt")
                .navigationTitle("End User License Agreement")) {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                            .foregroundColor(colorScheme == .dark ?
                                             Color.theme.systemBackgroundInvert :
                                                Color.theme.accent)
                        Text("End User License Agreement")
                    }
            }
        } header: {
            Text("Legal")
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()

        MenuView()
            .preferredColorScheme(.dark)
    }
}
