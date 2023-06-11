//
//  CustomTextField.swift
//  HGFcollective
//
//  Created by William Dolke on 06/01/2023.
//

import SwiftUI

struct CustomTextField<Field: Hashable>: View, Hashable where Field: Equatable {
    let title: String
    let text: Binding<String>
    let focusedField: FocusState<Field>.Binding
    let field: Field

    var body: some View {
        TextField(title, text: text)
            .accentColor(Color.theme.systemBackgroundInvert)
            .focused(focusedField, equals: field)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(text.wrappedValue)
        hasher.combine(field)
    }

    static func == (lhs: CustomTextField<Field>, rhs: CustomTextField<Field>) -> Bool {
        lhs.title == rhs.title &&
        lhs.text.wrappedValue == rhs.text.wrappedValue &&
        lhs.field == rhs.field
    }
}

struct CustomTextField_Previews: PreviewProvider {
    @State private static var text = ""
    @FocusState private static var fieldInFocus: PreviewField?

    enum PreviewField {
        case username
        case password
    }

    static var previews: some View {
        CustomTextField(title: "Enter text", text: $text, focusedField: $fieldInFocus, field: .username)

        CustomTextField(title: "Enter text", text: $text, focusedField: $fieldInFocus, field: .username)
            .preferredColorScheme(.dark)
    }
}
