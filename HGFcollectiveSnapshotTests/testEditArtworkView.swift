//
//  testEditArtworkView.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 30/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import HGFcollective

final class testEditArtworkView: XCTestCase {
    var editArtworkViewController: UIViewController!

    override func setUp() {
        super.setUp()
        let editArtworkView = EditArtworkView()
            .environmentObject(ArtistManager())
        editArtworkViewController = UIHostingController(rootView: editArtworkView)
    }

    override func tearDown() {
        super.tearDown()
        editArtworkViewController = nil
    }

    func testEditArtworkViewLight() throws {
        assertSnapshot(
            matching: editArtworkViewController,
            as: .image(on: .iPhoneX)
        )
    }

    func testEditArtworkViewDark() throws {
        assertSnapshot(
            matching: editArtworkViewController,
            as: .image(on: .iPhoneX, traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }
}
