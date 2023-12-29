//
//  TestReportView.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 30/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
import AccessibilitySnapshot
@testable import HGFcollective

final class TestReportView: XCTestCase {
    var reportViewController: UIViewController!

    override func setUp() {
        super.setUp()
        let reportView = ReportView()
            .environmentObject(EnquiryManager.shared)
        reportViewController = UIHostingController(rootView: reportView)
        reportViewController.view.frame = UIScreen.main.bounds
    }

    override func tearDown() {
        super.tearDown()
        reportViewController = nil
    }

    func testReportViewLight() throws {
        assertSnapshot(
            matching: reportViewController,
            as: .image(on: .iPhoneX)
        )
    }

    func testReportViewDark() throws {
        assertSnapshot(
            matching: reportViewController,
            as: .image(on: .iPhoneX, traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }

    func testReportViewAccessibility() throws {
        assertSnapshot(
            matching: reportViewController,
            as: .accessibilityImage(showActivationPoints: .always)
        )
    }
}
