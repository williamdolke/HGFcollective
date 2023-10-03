//
//  TestImageView.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 31/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
import AccessibilitySnapshot
@testable import HGFcollective

final class TestImageView: XCTestCase {
    var imageViewController: UIViewController!

    override func setUp() {
        super.setUp()
        let imageView = ImageView(artworkName:"Mr monopoly man")
        imageViewController = UIHostingController(rootView: imageView)
        imageViewController.view.frame = UIScreen.main.bounds
    }

    override func tearDown() {
        super.tearDown()
        imageViewController = nil
    }

    func testImageViewLight() throws {
        assertSnapshot(
            matching: imageViewController,
            as: .image(on: .iPhoneX)
        )
    }

    func testImageViewDark() throws {
        assertSnapshot(
            matching: imageViewController,
            as: .image(on: .iPhoneX, traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }

    func testImageViewAccessibility() throws {
        assertSnapshot(
            matching: imageViewController,
            as: .accessibilityImage(showActivationPoints: .always)
        )
    }
}

