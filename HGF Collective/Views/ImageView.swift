//
//  ImageView.swift
//  HGF Collective
//
//  Created by William Dolke on 19/09/2022.
//

import SwiftUI

struct ImageView: View {
    @EnvironmentObject var artistManager: ArtistManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var scale = 1.0
    @State private var lastScale = 1.0
    private let minScale = 1.0
    private let maxScale = 5.0
    
    var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { state in
                adjustScale(from: state)
            }
            .onEnded { state in
                withAnimation {
                    validateScaleLimits()
                }
                lastScale = 1.0
            }
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            TabView(selection: .constant(true)) {
                ForEach(["person.crop.artframe","person.crop.artframe"], id: \.self) {image in
                    Image(systemName: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .gesture(magnificationGesture)
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            
            // Close view button
            .overlay(
                Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.35))
                        .clipShape(Circle())
                }
                .padding()
                ,alignment: .topTrailing
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
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView()
    }
}
