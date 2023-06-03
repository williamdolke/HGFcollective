//
//  HTMLView.swift
//  HGFcollective
//
//  Created by William Dolke on 25/12/2022.
//

import SwiftUI
import WebKit

/// Convert a string to HTML and display the web page produced
struct HTMLView: UIViewRepresentable {
    let filePath: String
    let ofType: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let path = Bundle.main.path(forResource: filePath, ofType: ofType)
        let content = try? String(contentsOfFile: path!, encoding: String.Encoding.utf8)

        uiView.loadHTMLString(content ?? "", baseURL: nil)
    }
}

struct HTMLView_Previews: PreviewProvider {
    static var previews: some View {
        HTMLView(filePath: "PrivacyPolicy", ofType: "txt")

        HTMLView(filePath: "PrivacyPolicy", ofType: "txt")
            .preferredColorScheme(.dark)
    }
}
