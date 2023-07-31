//
//  TestConversationPreviewRow.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 30/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
import AccessibilitySnapshot
@testable import HGFcollective

final class TestConversationPreviewRow: XCTestCase {
    var conversationPreviewRowController: UIViewController!

    override func setUp() {
        super.setUp()
        let user = User(id: "test", messagePreview: "Test message.", latestTimestamp: Date.now, read: false, sender: "test", isCustomer: false)
        let conversationPreviewRow = ConversationPreviewRow(user: user)
        conversationPreviewRowController = UIHostingController(rootView: conversationPreviewRow)
        conversationPreviewRowController.view.frame = UIScreen.main.bounds
    }

    override func tearDown() {
        super.tearDown()
        conversationPreviewRowController = nil
    }

    func testConversationPreviewRowLight() throws {
        assertSnapshot(
            matching: conversationPreviewRowController,
            as: .image(on: .iPhoneX)
        )
    }

    func testConversationPreviewRowDark() throws {
        assertSnapshot(
            matching: conversationPreviewRowController,
            as: .image(on: .iPhoneX, traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }

    func testConversationPreviewRowAccessibility() throws {
        assertSnapshot(
            matching: conversationPreviewRowController,
            as: .accessibilityImage(showActivationPoints: .always)
        )
    }
}

