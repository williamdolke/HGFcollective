//
//  segmentedControl.swift
//  HGFcollective
//
//  Created by William Dolke on 22/01/2023.
//

import SwiftUI

struct segmentedControl: View {
    var body: some View {
        SegmentedPicker(
            ProfileSection.allCases,
            selectedIndex: Binding(
                get: { ProfileSection.index(of: segmentationSelection) },
                set: { segmentationSelection = ProfileSection.element(at: $0 ?? 0) ?? .grid }),
            content: { segment, isActive in
                // Display the text for each segmentationControl case
                Text(segment.rawValue)
                    .foregroundColor(isActive ? Color.theme.systemBackgroundInvert : Color.theme.tabBarInactive)
                    .padding()
            },
            selection: {
                // Horizontal line under the active case
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.theme.systemBackgroundInvert)
                        .frame(height: 2)
                }
            }
        )
        .animation(.easeInOut(duration: 0.3))
    }
}

struct segmentedControl_Previews: PreviewProvider {
    static var previews: some View {
        segmentedControl()
    }
}
