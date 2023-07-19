//
//  ReportView.swift
//  HGFcollective
//
//  Created by William Dolke on 27/12/2022.
//

import SwiftUI
import MessageUI
import ZIPFoundation
import Logging
import FirebaseAnalytics

struct ReportView: View {
    @EnvironmentObject var enquiryManager: EnquiryManager

    @State private var sendDiagsClicked = false
    @State private var showMailErrorAlert = false
    @State private var result: Result<MFMailComposeResult, Error>?

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("How to report a crash:")
                        .font(.title)
                    Spacer()
                }
                .padding()

                Text("""
                     1) To report a crash open the Settings app on the device.
                     2) Go to Privacy & Security > Analytics & Improvements > Analytics Data.
                     3) Search for items starting with the name of the app.
                     4) Tap an item with the date of the crash.
                     5) Tap the share icon in the upper right, and select Mail.
                     6) Send the crash report as a mail attachment to \
                     \(enquiryManager.mail.problemReportRecipients.joined(separator: ", "))
                     """
                )
                .padding()

                Button {
                    if MFMailComposeViewController.canSendMail() {
                        sendDiagsClicked.toggle()
                    } else {
                        logger.error("Device is not configured to send mail, cannot present mail view.")
                        showMailErrorAlert.toggle()
                    }
                } label: {
                    HStack {
                        Text("**Send diagnostics**")
                            .font(.title2)
                        Image(systemName: "envelope")
                    }
                    .padding()
                    .foregroundColor(Color.theme.buttonForeground)
                    .background(Color.theme.accent)
                    .cornerRadius(40)
                    .shadow(radius: 8, x: 8, y: 8)
                }
                .contentShape(Rectangle())
                .padding(.bottom, 10)
            }
            .sheet(isPresented: $sendDiagsClicked) {
                let logFileURL = getLogFileURL()
                MailView(presentation: $sendDiagsClicked,
                         result: $result,
                         recipients: enquiryManager.mail.problemReportRecipients,
                         subject: "HGF Collective Problem Report",
                         body: "Please enter a clear and detailed description of the problem:",
                         fileURL: logFileURL,
                         mimeType: "application/zip",
                         fileName: "HGFcollective.zip")
            }
            .alert(isPresented: $showMailErrorAlert) {
                Alert(title: Text("Mail Account Is Not Configured"),
                      message: Text("""
                                    Unable to compose an email. \
                                    Please install the Mail app and sign in to an email account to proceed.
                                    """),
                      dismissButton: .default(Text("OK"), action: { logger.info("Mail error alert dismissed.") }))
            }
            .onAppear {
                logger.info("Presenting report view.")

                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "\(ReportView.self)",
                                               AnalyticsParameterScreenClass: "\(ReportView.self)"])
            }
        }
    }

    private func getLogFileURL() -> URL? {
        // Retrieve the log file URL
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let logFileURL = documentDirectory?.appendingPathComponent("HGFcollective.log")

        // Create a temporary directory for the zip file
        let tempDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent("Logs")

        do {
            try FileManager.default.createDirectory(at: tempDirectoryURL,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)

            // Move the log file to the temporary directory
            let tempLogFileURL = tempDirectoryURL.appendingPathComponent("HGFcollective.log")
            do {
                // Delete any existing/old log files
                let oldZipFileURL = tempDirectoryURL.appendingPathComponent("HGFcollective.zip")
                try FileManager.default.removeItem(at: oldZipFileURL)
            } catch {
                print("Error deleting zip file: \(error)")
            }
            try FileManager.default.copyItem(at: logFileURL!, to: tempLogFileURL)

            // Create a zip file containing the log file
            let zipFileURL = tempDirectoryURL.appendingPathComponent("HGFcollective.zip")
            try FileManager.default.zipItem(at: tempLogFileURL, to: zipFileURL)

            // Delete the temporary log file
            try FileManager.default.removeItem(at: tempLogFileURL)

            return zipFileURL
        } catch {
            print("Error creating zip file: \(error)")
            return nil
        }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView()

        ReportView()
            .preferredColorScheme(.dark)
    }
}
