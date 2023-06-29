//
//  SubmitButton.swift
//  HGFcollective
//
//  Created by William Dolke on 28/06/2023.
//

import SwiftUI

struct SubmitButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            logger.info("User tapped the submit button")
            action()
        } label: {
            HStack {
                Text("Submit")
                    .font(.title2)
                Image(systemName: "checkmark.icloud")
            }
            .padding()
            .foregroundColor(Color.theme.buttonForeground)
            .background(Color.theme.accent)
            .cornerRadius(40)
            .shadow(radius: 8, x: 8, y: 8)
        }
        .contentShape(Rectangle())
        .padding(.bottom, 10)
    }
}

struct SubmitButton_Previews: PreviewProvider {
    static var previews: some View {
        SubmitButton(action: {})

        SubmitButton(action: {})
            .preferredColorScheme(.dark)
    }
}
