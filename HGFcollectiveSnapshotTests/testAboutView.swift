//
//  testAboutView.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 30/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import HGFcollective

final class testAboutView: XCTestCase {
    var aboutViewController: UIViewController!

    override func setUp() {
        super.setUp()
        let aboutView = AboutView()
        aboutViewController = UIHostingController(rootView: aboutView)
    }

    override func tearDown() {
        super.tearDown()
        aboutViewController = nil
    }

    func testAboutViewLight() throws {
        assertSnapshot(
            matching: aboutViewController,
            as: .image(on: .iPhoneX)
        )
    }

    func testAboutViewDark() throws {
        assertSnapshot(
            matching: aboutViewController,
            as: .image(on: .iPhoneX, traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }
}
