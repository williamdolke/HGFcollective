//
//  cornerRadius.swift
//  HGF Collective
//
//  Created by William Dolke on 12/09/2022.
//

import Foundation
import SwiftUI

/// Extension for adding rounded corners to specified corners of a View
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
}

/// Custom RoundedCorner shape used by the cornerRadius extension
struct RoundedCorner: Shape {
    // Radius applied to all corners to be rounded
    var radius: CGFloat = .infinity
    // Which corners the radius is applied to. Defaults to all corners.
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
