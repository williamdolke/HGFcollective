//
//  AboutView.swift
//  HGFcollective
//
//  Created by William Dolke on 25/12/2022.
//

import SwiftUI
import FirebaseAnalytics

struct AboutView: View {
    // AppStorage is a property wrapper for accessing values stored in UserDefaults
    @AppStorage("aboutScreenShown")
    var aboutScreenShown: Bool = false

    let path = Bundle.main.path(forResource: "About", ofType: "txt")

    var body: some View {
        // The GeometryReader needs to be defined outside the ScrollView, otherwise it won't
        // take the dimensions of the screen
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack {
                    let squareDimension = 0.4 * min(geo.size.height, geo.size.width)

                    Image("IconSquare")
                        .resizable()
                        .frame(width: squareDimension, height: squareDimension)
                        .padding()

                    let content = try? String(contentsOfFile: path!, encoding: String.Encoding.utf8)

                    Text(content ?? "")
                        .padding()
                        .background(.ultraThinMaterial,
                                    in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                    // Show the dismiss button if this is the first time launching the app
                    if !UserDefaults.standard.bool(forKey: "aboutScreenShown") {
                        dismissButton
                    }
                }
                .padding()
            }
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "\(AboutView.self)",
                                               AnalyticsParameterScreenClass: "\(AboutView.self)"])
            }
        }
    }

    private var dismissButton: some View {
        Button {
            aboutScreenShown = true
            logger.info("User tapped the dismiss button")
        } label: {
            HStack {
                Text("**Dismiss**")
                    .font(.title2)
            }
            .padding()
            .background(Color.theme.accent)
            .cornerRadius(40)
            .foregroundColor(Color.theme.buttonForeground)
        }
        .contentShape(Rectangle())
        .padding(.bottom, 10)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()

        AboutView()
            .preferredColorScheme(.dark)
    }
}
