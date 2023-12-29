//
//  TestEditArtworkView.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 30/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
import AccessibilitySnapshot
@testable import HGFcollective

final class TestEditArtworkView: XCTestCase {
    var editArtworkViewController: UIViewController!

    override func setUp() {
        super.setUp()
        let editArtworkView = EditArtworkView()
            .environmentObject(ArtistManager.shared)
        editArtworkViewController = UIHostingController(rootView: editArtworkView)
        editArtworkViewController.view.frame = UIScreen.main.bounds
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

    func testEditArtworkViewAccessibility() throws {
        assertSnapshot(
            matching: editArtworkViewController,
            as: .accessibilityImage(showActivationPoints: .always)
        )
    }
}
