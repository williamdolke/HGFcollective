//
//  Color.swift
//  HGF Collective
//
//  Created by William Dolke on 19/09/2022.
//

import Foundation
import SwiftUI

// Custom colour theme
extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let accent = Color("AccentColor")
    let accentSecondary = Color("AccentColorSecondary")
    let bubble = Color("BubbleColor")
    let buttonForeground = Color("ButtonForegroundColor")
    let favourite = Color("FavouriteColor")
    let imageBackground = Color("ImageBackground")
    let systemBackground = Color("SystemBackground")
}
