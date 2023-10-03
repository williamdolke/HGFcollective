//
//  TestInboxView.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 31/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
import AccessibilitySnapshot
@testable import HGFcollective

final class TestInboxView: XCTestCase {
    var inboxViewController: UIViewController!

    override func setUp() {
        super.setUp()
        let inboxView = InboxView(userManager: MockUserManager())
        inboxViewController = UIHostingController(rootView: inboxView)
        inboxViewController.view.frame = UIScreen.main.bounds
    }

    override func tearDown() {
        super.tearDown()
        inboxViewController = nil
    }

    func testInboxViewLight() throws {
        assertSnapshot(
            matching: inboxViewController,
            as: .image(on: .iPhoneX)
        )
    }

    func testInboxViewDark() throws {
        assertSnapshot(
            matching: inboxViewController,
            as: .image(on: .iPhoneX, traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }

    func testInboxViewAccessibility() throws {
        assertSnapshot(
            matching: inboxViewController,
            as: .accessibilityImage(showActivationPoints: .always)
        )
    }
}
