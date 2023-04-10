//
//  LaunchScreen.swift
//  HGF Collective
//
//  Created by William Dolke on 17/09/2022.
//

import SwiftUI
import FirebaseAnalytics

struct LaunchScreen: View {
    @State private var isActive = false // True when ContentView is presented
    @State private var size = 0.8
    @State private var opacity = 0.5

    var body: some View {
        if isActive {
            ContentView()
        } else {
            logoAnimation
                .onAppear {
                    logger.info("Presenting launch screen.")

                    // Switch to the home view tab after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        isActive = true
                    }
                }
        }
    }

    // Increase the size and opacity of the app logo for a short duration
    private var logoAnimation: some View {
        VStack {
            Image("IconSquare")
                .resizable()
                .frame(width: 250, height: 250)
                .cornerRadius(30)
        }
        .scaleEffect(size)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 1.5)) {
                size = 0.9
                opacity = 1.0
            }

            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "\(LaunchScreen.self)",
                                           AnalyticsParameterScreenClass: "\(LaunchScreen.self)"])
        }
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static let artistManager = ArtistManager()

    static var previews: some View {
        LaunchScreen()
            .environmentObject(artistManager)

        LaunchScreen()
            .environmentObject(artistManager)
            .preferredColorScheme(.dark)
    }
}
