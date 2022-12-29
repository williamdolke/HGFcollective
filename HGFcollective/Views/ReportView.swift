//
//  ReportView.swift
//  HGFcollective
//
//  Created by William Dolke on 27/12/2022.
//

import SwiftUI

struct ReportView: View {
    var body: some View {
        VStack {
            Text("Report a crash:")
                .font(.title2)
            Text("""
             1) To report a crash open the Settings app on the device.
             2) Go to Privacy & Security > Analytics & Improvements > Analytics Data.
             3) Search for items starting with the name of the app.
             4) Tap an item with the date of the crash.
             5) Tap the share icon in the upper right, and select Mail.
             6) Send the crash report as a mail attachment to williamdolke@gmail.com
             """)
            .padding()
        }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView()
    }
}
