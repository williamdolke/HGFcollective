//
//  LaunchScreen.swift
//  HGF Collective
//
//  Created by William Dolke on 17/09/2022.
//

import SwiftUI

struct LaunchScreen: View {
    @State private var isActive = false // True when ContentView is presented
    @State private var size = 0.8
    @State private var opacity = 0.5

    var body: some View {
        if isActive {
            ContentView()
                // Fetch the chat messages when the content view appears. Hopefully
                // this will be complete before the user taps on the chat tab. If not,
                // the app will crash if this is the first install.
                // swiftlint:disable force_cast
                .environmentObject(MessagesManager(uid: UserDefaults.standard.object(forKey: "uid") as! String))
                // swiftlint:enable force_cast
        } else {
            logoAnimation
                .onAppear {
                    logger.info("Presenting launch screen.")

                    // Switch to the home view tab after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        self.isActive = true
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
        }
        .scaleEffect(size)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 1.5)) {
                self.size = 0.9
                self.opacity = 1.0
            }
        }
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static let artistManager = ArtistManager()

    static var previews: some View {
        LaunchScreen()
            .environmentObject(artistManager)
            .environmentObject(MessagesManager(uid: "test"))

        LaunchScreen()
            .environmentObject(artistManager)
            .environmentObject(MessagesManager(uid: "test"))
            .preferredColorScheme(.dark)
    }
}
