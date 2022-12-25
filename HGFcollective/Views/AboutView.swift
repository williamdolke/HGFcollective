//
//  AboutView.swift
//  HGFcollective
//
//  Created by William Dolke on 25/12/2022.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            Image("IconSquare")
                .resizable()
                .frame(width: 150, height: 150)

            Text("Hi, we're HGF Collective!")
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
