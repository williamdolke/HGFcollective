//
//  ImageView.swift
//  HGF Collective
//
//  Created by William Dolke on 19/09/2022.
//

import SwiftUI

struct ImageView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var scale = 1.0
    @State private var lastScale = 1.0
    @State private var location = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height*0.4)
    @GestureState private var locationState = CGPoint(x: UIScreen.main.bounds.size.width/2,
                                                      y: UIScreen.main.bounds.size.height*0.4)

    private let minScale = 1.0
    private let maxScale = 5.0
    private let defaultLocation = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height*0.4)

    var artwork: Artwork?
    var imageNum: String?
    var url: String?

    var body: some View {
        ZStack {
            Color.theme.imageBackground
                .ignoresSafeArea()

            fullScreenImage
            // Overlay a button to close the view
            .overlay(
                closeButton
                .padding()
                , alignment: .topTrailing
            )
        }
    }

    private var fullScreenImage: some View {
        GeometryReader { geo in
            ImageBubble(assetName: (artwork?.name ?? "") + " " + (imageNum ?? "1"),
                        url: url,
                        height: geo.size.height,
                        width: geo.size.width)
                .aspectRatio(contentMode: .fit)
                .position(location)
                .scaleEffect(scale)
                .gesture(dragGesture)
                .gesture(magnificationGesture)
                .foregroundColor(Color.theme.buttonForeground)
        }
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(Color.theme.buttonForeground)
                .padding()
                .background(Color.theme.buttonForeground.opacity(0.35))
                .clipShape(Circle())
        }
    }

    var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { state in
                adjustScale(from: state)
            }
            .onEnded { _ in
                withAnimation {
                    // When the gesture ends, check that the
                    // image is in an allowed state
                    validateScaleLimits()
                    lastScale = 1.0
                    maybeResetLocation()
                }
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
                // When the gesture ends, check that the
                // image is in an allowed state
                withAnimation {
                    maybeResetLocation()
                }
            }
    }

    /// Scale the image when the user perform the magnification gesture
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

    /// Ensure the image scale is within the allowed range
    func validateScaleLimits() {
        scale = getMinimumScaleAllowed()
        scale = getMaximumScaleAllowed()
    }

    /// Reset the image location if the user zooms out and releases
    func maybeResetLocation() {
        if scale <= 1.0 {
            location = defaultLocation
        }
    }

    /// Ensure the image location coordinates are within the allowed ranges
    func limitLocation() {
        // Bound the x coordinate
        if location.x >= defaultLocation.x {
            location.x = min(location.x, 1.5*defaultLocation.x)
        } else {
            location.x = max(location.x, 0.5*defaultLocation.x)
        }

        // Bound the y coordinate
        if location.y >= defaultLocation.y {
            location.y = min(location.y, 1.25*defaultLocation.y)
        } else {
            location.y = max(location.y, 0.75*defaultLocation.y)
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(artwork: Artwork(name: "Artwork"))

        ImageView(artwork: Artwork(name: "Artwork"))
            .preferredColorScheme(.dark)
    }
}
