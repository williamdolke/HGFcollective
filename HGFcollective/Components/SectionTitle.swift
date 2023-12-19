//
//  SectionTitle.swift
//  HGFcollective
//
//  Created by William Dolke on 12/12/2023.
//

import SwiftUI

struct SectionTitle: View {
    var title: String
    @Binding var isExpanded: Bool
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button {
            withAnimation {
                isExpanded.toggle()
            }
        } label: {
            HStack {
                Text(title)
                    .font(.headline)

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(colorScheme == .dark ? Color.theme.systemBackgroundInvert : Color.theme.accent)
            .padding()
        }
    }
}

#Preview("Light") {
    SectionTitle(title: "Section", isExpanded: .constant(true))
}

#Preview("Dark") {
    SectionTitle(title: "Section", isExpanded: .constant(false))
        .preferredColorScheme(.dark)
}
