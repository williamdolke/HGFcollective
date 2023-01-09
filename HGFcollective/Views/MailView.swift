//
//  MailView.swift
//  HGF Collective
//
//  Created by William Dolke on 11/09/2022.
//

import Foundation
import SwiftUI
import UIKit
import MessageUI
import FirebaseCrashlytics

struct MailView: UIViewControllerRepresentable {
    @EnvironmentObject var enquiryManager: EnquiryManager
    @Binding var presentation: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?

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
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: $presentation,
                           result: $result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = context.coordinator

        logger.info("Setting email recipient.")
        mailVC.setToRecipients(enquiryManager.mail.recipients)

        logger.info("Setting email subject.")
        mailVC.setSubject(enquiryManager.mail.subject ?? "")

        logger.info("Setting email message body.")
        mailVC.setMessageBody(enquiryManager.mail.msgBody ?? "", isHTML: false)
        return mailVC
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {
        // Update MailView when the database response is received
        uiViewController.setToRecipients(enquiryManager.mail.recipients)
        uiViewController.setSubject(enquiryManager.mail.subject ?? "")
        uiViewController.setMessageBody(enquiryManager.mail.msgBody ?? "", isHTML: false)
    }
}
