//
//  TestMenuView.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 30/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
import AccessibilitySnapshot
@testable import HGFcollective

final class TestMenuView: XCTestCase {
    var menuViewController: UIViewController!

    override func setUp() {
        super.setUp()
        let menuView = MenuView()
        menuViewController = UIHostingController(rootView: menuView)
        menuViewController.view.frame = UIScreen.main.bounds
    }

    override func tearDown() {
        super.tearDown()
        menuViewController = nil
    }

    func testMenuViewLight() throws {
        assertSnapshot(
            matching: menuViewController,
            as: .image(on: .iPhoneX)
        )
    }

    func testMenuViewDark() throws {
        assertSnapshot(
            matching: menuViewController,
            as: .image(on: .iPhoneX, traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }

    func testMenuViewAccessibility() throws {
        assertSnapshot(
            matching: menuViewController,
            as: .accessibilityImage(showActivationPoints: .always)
        )
    }
}
