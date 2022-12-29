//
//  MenuView.swift
//  HGFcollective
//
//  Created by William Dolke on 25/12/2022.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        NavigationView {
            Form {
                generalSection
                legalSection
            }
        }
        .navigationTitle("Menu")
    }

    var generalSection: some View {
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

    var legalSection: some View {
        Section {
            NavigationLink(destination: HTMLView(filePath: "PrivacyPolicy", ofType: "txt")) {
                Text("Privacy Policy")
            }
            NavigationLink(destination: HTMLView(filePath: "TermsAndConditions", ofType: "txt")) {
                Text("Terms and Conditions")
            }
            NavigationLink(destination: HTMLView(filePath: "EULA", ofType: "txt")) {
                Text("End User License Agreement (EULA)")
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
