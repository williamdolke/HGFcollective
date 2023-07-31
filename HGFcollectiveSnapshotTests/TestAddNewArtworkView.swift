//
//  TestAddNewArtworkView.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 30/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
import AccessibilitySnapshot
@testable import HGFcollective

final class TestAddNewArtworkView: XCTestCase {
    var addNewArtworkViewController: UIViewController!

    override func setUp() {
        super.setUp()
        let addNewArtworkView = AddNewArtworkView()
        addNewArtworkViewController = UIHostingController(rootView: addNewArtworkView)
        addNewArtworkViewController.view.frame = UIScreen.main.bounds
    }

    override func tearDown() {
        super.tearDown()
        addNewArtworkViewController = nil
    }

    func testAddNewArtworkViewLight() throws {
        assertSnapshot(
            matching: addNewArtworkViewController,
            as: .image(on: .iPhoneX)
        )
    }

    func testAddNewArtworkViewDark() throws {
        assertSnapshot(
            matching: addNewArtworkViewController,
            as: .image(on: .iPhoneX, traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }

    func testAddNewArtworkViewAccessibility() throws {
        assertSnapshot(
            matching: addNewArtworkViewController,
            as: .accessibilityImage(showActivationPoints: .always)
        )
    }
}
