//
//  ImageView.swift
//  HGF Collective
//
//  Created by William Dolke on 19/09/2022.
//

import SwiftUI

struct ImageView: View {
    @EnvironmentObject var artistManager: ArtistManager
    @Environment(\.dismiss) private var dismiss

    @State private var scale = 1.0
    @State private var lastScale = 1.0
    @State private var location = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height*0.4)
    @GestureState private var locationState = CGPoint(x: UIScreen.main.bounds.size.width/2,
                                                      y: UIScreen.main.bounds.size.height*0.4)

    private let minScale = 1.0
    private let maxScale = 5.0
    private let defaultLocation = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height*0.4)

    var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { state in
                adjustScale(from: state)
            }
            .onEnded { _ in
                withAnimation {
                    validateScaleLimits()
                }
                lastScale = 1.0
                maybeResetLocation()
            }
    }

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { state in
                location.x += (state.predictedEndLocation.x - state.startLocation.x)/(0.1*defaultLocation.x)
                location.y += (state.predictedEndLocation.y - state.startLocation.y)/(0.1*defaultLocation.y)
                limitLocation()
            }
            .onEnded { _ in
                withAnimation {
                    maybeResetLocation()
                }
            }
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Image(systemName: "person.crop.artframe")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .position(location)
                .scaleEffect(scale)
                .gesture(dragGesture)
                .gesture(magnificationGesture)
                .font(.system(size: 80))
                .foregroundColor(.white)

            // Close view button
            .overlay(
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.35))
                        .clipShape(Circle())
                }
                .padding()
                , alignment: .topTrailing
            )
        }
    }

    func adjustScale(from state: MagnificationGesture.Value) {
        let delta = state / lastScale
        scale *= delta
        lastScale = state
    }

    func getMinimumScaleAllowed() -> CGFloat {
        return max(minScale, scale)
    }

    func getMaximumScaleAllowed() -> CGFloat {
        return min(maxScale, scale)
    }

    func validateScaleLimits() {
        scale = getMinimumScaleAllowed()
        scale = getMaximumScaleAllowed()
    }

    func maybeResetLocation() {
        if scale <= 1.0 {
            location = defaultLocation
        }
    }

    func limitLocation() {
        if location.x >= defaultLocation.x {
            location.x = min(location.x, 1.5*defaultLocation.x)
        } else {
            location.x = max(location.x, 0.5*defaultLocation.x)
        }

        if location.y >= defaultLocation.y {
            location.y = min(location.y, 1.25*defaultLocation.y)
        } else {
            location.y = max(location.y, 0.75*defaultLocation.y)
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView()

        ImageView()
            .preferredColorScheme(.dark)
    }
}
