//
//  EnquireView.swift
//  ArtApp
//
//  Created by William Dolke on 11/09/2022.
//

import MessageUI
import SwiftUI

struct EnquireView: View {
    @State private var result: Result<MFMailComposeResult, Error>? = nil
    
    var body: some View {
        ZStack(alignment: .top) {
            Capsule()
                .fill(Color.secondary)
                .opacity(0.5)
                .frame(width: 35, height: 5)
                .padding(6)
            
            Spacer()
        }
    }
}

struct EnquireView_Previews: PreviewProvider {
    static var previews: some View {
        EnquireView()
    }
}
