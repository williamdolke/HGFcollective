//
//  TestMessageField.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 30/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
import AccessibilitySnapshot
@testable import HGFcollective

final class TestMessageField: XCTestCase {
    var messageFieldController: UIViewController!

    override func setUp() {
        super.setUp()
        let messageField = MessageField()
        messageFieldController = UIHostingController(rootView: messageField)
        messageFieldController.view.frame = UIScreen.main.bounds
    }

    override func tearDown() {
        super.tearDown()
        messageFieldController = nil
    }

    func testMessageFieldLight() throws {
        assertSnapshot(
            matching: messageFieldController,
            as: .image(on: .iPhoneX)
        )
    }

    func testMessageFieldDark() throws {
        assertSnapshot(
            matching: messageFieldController,
            as: .image(on: .iPhoneX, traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }

    func testMessageFieldAccessibility() throws {
        assertSnapshot(
            matching: messageFieldController,
            as: .accessibilityImage(showActivationPoints: .always)
        )
    }
}
