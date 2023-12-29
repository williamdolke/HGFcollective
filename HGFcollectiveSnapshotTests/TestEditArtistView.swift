//
//  TestEditArtistView.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 30/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
import AccessibilitySnapshot
@testable import HGFcollective

final class TestEditArtistView: XCTestCase {
    var editArtistViewController: UIViewController!

    override func setUp() {
        super.setUp()
        let editArtistView = EditArtistView()
            .environmentObject(ArtistManager.shared)
        editArtistViewController = UIHostingController(rootView: editArtistView)
        editArtistViewController.view.frame = UIScreen.main.bounds
    }

    override func tearDown() {
        super.tearDown()
        editArtistViewController = nil
    }

    func testEditArtistViewLight() throws {
        assertSnapshot(
            matching: editArtistViewController,
            as: .image(on: .iPhoneX)
        )
    }

    func testEditArtistViewDark() throws {
        assertSnapshot(
            matching: editArtistViewController,
            as: .image(on: .iPhoneX, traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }

    func testEditArtistViewAccessibility() throws {
        assertSnapshot(
            matching: editArtistViewController,
            as: .accessibilityImage(showActivationPoints: .always)
        )
    }
}
