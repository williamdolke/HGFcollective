//
//  TestPortfolioManagerView.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 31/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
import AccessibilitySnapshot
@testable import HGFcollective

final class TestPortfolioManagerView: XCTestCase {
    var portfolioManagerViewController: UIViewController!

    override func setUp() {
        super.setUp()
        let portfolioManagerView = PortfolioManagerView()
        portfolioManagerViewController = UIHostingController(rootView: portfolioManagerView)
        portfolioManagerViewController.view.frame = UIScreen.main.bounds
    }

    override func tearDown() {
        super.tearDown()
        portfolioManagerViewController = nil
    }

    func testPortfolioManagerViewLight() throws {
        assertSnapshot(
            matching: portfolioManagerViewController,
            as: .image(on: .iPhoneX)
        )
    }

    func testPortfolioManagerViewDark() throws {
        assertSnapshot(
            matching: portfolioManagerViewController,
            as: .image(on: .iPhoneX, traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }

    func testPortfolioManagerViewAccessibility() throws {
        assertSnapshot(
            matching: portfolioManagerViewController,
            as: .accessibilityImage(showActivationPoints: .always)
        )
    }
}
