//
//  LaunchScreen.swift
//  HGF Collective
//
//  Created by William Dolke on 17/09/2022.
//

import SwiftUI

struct LaunchScreen: View {
    @EnvironmentObject var artistManager: ArtistManager

    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5

    var body: some View {
        if isActive {
            ContentView()
                .environmentObject(artistManager)
                .environmentObject(MessagesManager(uid: UserDefaults.standard.object(forKey: "uid") as! String))
        } else {
            logoAnimation
                .onAppear {
                    logger.info("Presenting launch screen.")

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
        }
    }

    private var logoAnimation: some View {
        VStack {
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
