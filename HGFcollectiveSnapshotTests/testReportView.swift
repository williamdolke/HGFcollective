//
//  testReportView.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 30/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import HGFcollective

final class testReportView: XCTestCase {
    var reportViewController: UIViewController!

    override func setUp() {
        super.setUp()
        let reportView = ReportView()
            .environmentObject(EnquiryManager())
        reportViewController = UIHostingController(rootView: reportView)
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
}
