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
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        print("Setting recipient")
        vc.setToRecipients(enquiryManager.mail.recipients)
        print("Set recipient")
        vc.setSubject(enquiryManager.mail.subject ?? "")
        vc.setMessageBody(enquiryManager.mail.msgBody ?? "", isHTML: false)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {
        // Update MailView when the database response is received
        uiViewController.setToRecipients(enquiryManager.mail.recipients)
        uiViewController.setSubject(enquiryManager.mail.subject ?? "")
        uiViewController.setMessageBody(enquiryManager.mail.msgBody ?? "", isHTML: false)
    }
}
