//
//  MailView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import Foundation
import SwiftUI
import MessageUI
import FirebaseAnalytics
import FirebaseCrashlytics

struct MailView: UIViewControllerRepresentable {
    @Binding var presentation: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?
    var recipients: [String] = []
    var subject: String = ""
    var body: String = ""
    let fileURL: URL?
    let mimeType: String?
    let fileName: String?

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentation: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(presentation: Binding<Bool>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentation = presentation
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                presentation = false
            }
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                self.result = .failure(error)
                return
            }
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: $presentation,
                           result: $result)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = context.coordinator

        Analytics.logEvent(AnalyticsEventScreenView,
                           parameters: [AnalyticsParameterScreenName: "\(MailView.self)",
                                       AnalyticsParameterScreenClass: "\(MailView.self)"])

        logger.info("Setting email recipient to \(recipients.joined(separator: ", ")).")
        mailVC.setToRecipients(recipients)

        logger.info("Setting email subject to \(subject).")
        mailVC.setSubject(subject)

        logger.info("Setting email message body to \(body).")
        mailVC.setMessageBody(body, isHTML: false)

        if fileURL != nil {
            logger.info("Setting attachment data.")
            if let attachmentData = try? Data(contentsOf: fileURL!) {
                mailVC.addAttachmentData(attachmentData, mimeType: mimeType!, fileName: fileName!)
            }
        }

        return mailVC
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {
        // Update MailView when the database response is received
        uiViewController.setToRecipients(recipients)
        uiViewController.setSubject(subject)
        uiViewController.setMessageBody(body, isHTML: false)
    }

    // This view doesn't have a preview as it doesn't work on simulators
}
