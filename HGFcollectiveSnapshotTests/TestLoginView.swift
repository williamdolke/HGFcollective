//
//  TestLoginView.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 30/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
import AccessibilitySnapshot

@testable import HGFcollective

final class TestLoginView: XCTestCase {
    var loginViewController: UIViewController!

    override func setUp() {
        super.setUp()
        let loginView = LoginView()
        loginViewController = UIHostingController(rootView: loginView)
        loginViewController.view.frame = UIScreen.main.bounds
    }

    override func tearDown() {
        super.tearDown()
        loginViewController = nil
    }

    func testLoginViewLight() throws {
        assertSnapshot(
            matching: loginViewController,
            as: .image(on: .iPhoneX)
        )
    }

    func testLoginViewDark() throws {
        assertSnapshot(
            matching: loginViewController,
            as: .image(on: .iPhoneX, traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }

    func testLoginViewAccessibility() throws {
        assertSnapshot(
            matching: loginViewController,
            as: .accessibilityImage(showActivationPoints: .always)
        )
    }
}
