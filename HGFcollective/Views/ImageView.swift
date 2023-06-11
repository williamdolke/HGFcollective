//
//  ImageView.swift
//  HGF Collective
//
//  Created by William Dolke on 19/09/2022.
//

import SwiftUI
import FirebaseAnalytics

struct ImageView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGPoint = .zero
    @State private var lastTranslation: CGSize = .zero

    private let minScale: CGFloat = 1
    private let maxScale: CGFloat = 5

    var artworkName: String?
    var imageNum: String?
    var url: String?

    var body: some View {
        ZStack {
            Color.theme.imageBackground
                .ignoresSafeArea()

            fullScreenImage
            // Overlay a button to close the view
            .overlay(closeButton, alignment: .topTrailing)
        }
        .onAppear {
            logger.info("Presenting image view.")

            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "\(artworkName ?? "nil")",
                                           AnalyticsParameterScreenClass: "\(ImageView.self)"])
        }
    }

    private var fullScreenImage: some View {
        GeometryReader { geo in
            ImageBubble(assetName: (artworkName ?? "") + " " + (imageNum ?? "1"),
                        url: url,
                        height: geo.size.height,
                        width: geo.size.width)
            .aspectRatio(contentMode: .fit)
            .scaleEffect(scale)
            .offset(x: offset.x, y: offset.y)
            .onTapGesture(count: 2, perform: onImageDoubleTapped)
            .gesture(dragGesture(size: geo.size))
            .gesture(magnificationGesture(size: geo.size))
            .foregroundColor(Color.theme.buttonForeground)
        }
    }

    /// Reset the scale and offset
    func resetState() {
        withAnimation(.interactiveSpring()) {
            scale = minScale
            offset = .zero
        }
    }

    /// When the user double taps the image either zoom in to the center or reset the view
    func onImageDoubleTapped() {
        if scale == minScale {
            // Zoom in
            withAnimation(.spring()) {
                scale = maxScale
            }
        } else {
            // Zoom out
            resetState()
        }
    }

    /// Close button to allow the user to dismiss the image presented
    private var closeButton: some View {
        Button {
            dismiss()
            logger.info("User pressed the close button to dismiss the view")
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(Color.theme.buttonForeground)
                .padding()
                .background(Color.theme.buttonForeground.opacity(0.35))
                .clipShape(Circle())
        }
        // Don't show the close button if the image is zoomed in
        .opacity(scale != minScale ? 0.0 : 1.0)
        .disabled(scale != minScale)
        .padding()
    }

    /// Scale the image when the user perform the magnification gesture
    private func adjustScale(from state: MagnificationGesture.Value) {
        let delta = state / lastScale
        lastScale = state

        // To minimize jittering
        if abs(1 - delta) > 0.01 {
            scale *= delta
        }
    }

    /// Ensure the image scale is within the allowed range
    private func validateScaleLimits() {
        scale = getMinimumScaleAllowed()
        scale = getMaximumScaleAllowed()
    }

    private func getMinimumScaleAllowed() -> CGFloat {
        return max(minScale, scale)
    }

    private func getMaximumScaleAllowed() -> CGFloat {
        return min(maxScale, scale)
    }

    /// Allow the user to zoom in with a pinch gesture
    private func magnificationGesture(size: CGSize) -> some Gesture {
        MagnificationGesture()
            .onChanged { state in
                adjustScale(from: state)
            }
            .onEnded { _ in
                lastScale = 1
                withAnimation {
                    validateScaleLimits()
                }
                adjustMaxOffset(size: size)
            }
    }

    /// Allow the user to pan around the image with a one fingered drag gesture
    private func dragGesture(size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let diff = CGPoint(
                    x: value.translation.width - lastTranslation.width,
                    y: value.translation.height - lastTranslation.height
                )
                offset = .init(x: offset.x + diff.x, y: offset.y + diff.y)
                lastTranslation = value.translation
            }
            .onEnded { _ in
                adjustMaxOffset(size: size)
            }
    }

    /// Ensure that the user doesn't navigate out of the image boundary
    private func adjustMaxOffset(size: CGSize) {
        let maxOffsetX = (size.width * (scale - 1)) / 2
        let maxOffsetY = (size.height * (scale - 1)) / 2

        var newOffset = offset

        if abs(newOffset.x) > maxOffsetX {
            newOffset.x = maxOffsetX * (abs(newOffset.x) / newOffset.x)
        }
        if abs(newOffset.y) > maxOffsetY {
            newOffset.y = maxOffsetY * (abs(newOffset.y) / newOffset.y)
        }

        if newOffset != offset {
            withAnimation {
                offset = newOffset
            }
        }
        lastTranslation = .zero
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(artworkName: "Artwork")

        ImageView(artworkName: "Artwork")
            .preferredColorScheme(.dark)
    }
}
