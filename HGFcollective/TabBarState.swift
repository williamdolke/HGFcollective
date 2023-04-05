//
//  TabBarState.swift
//  HGFcollective
//
//  Created by William Dolke on 02/04/2023.
//

import Foundation

class TabBarState: ObservableObject {
    @Published var selection: Int = 0
    @Published var unreadMessages: Int = 0
}
