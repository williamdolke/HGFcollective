//
//  CustomTextField.swift
//  HGFcollective
//
//  Created by William Dolke on 06/01/2023.
//

import SwiftUI

struct CustomTextField: View {
    let title: String
    let text: Binding<String>
    let isFocused: FocusState<Bool>.Binding
    let onTap: () -> Void

    var body: some View {
        TextField(title, text: text)
            .accentColor(Color.theme.systemBackgroundInvert)
            .focused(isFocused)
            // Allows the user to tap anywhere, including
            // the padded area, to focus the text field
            .onTapGesture {
                onTap()
            }
    }
}

struct CustomTextField_Previews: PreviewProvider {
    @State private static var text = ""
    @FocusState private static var isFocused: Bool

    static var previews: some View {
        CustomTextField(title: "Enter text", text: $text, isFocused: $isFocused, onTap: {})

        CustomTextField(title: "Enter text", text: $text, isFocused: $isFocused, onTap: {})
            .preferredColorScheme(.dark)
    }
}
