//
//  testConversationPreviewRow.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 30/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import HGFcollective

final class testConversationPreviewRow: XCTestCase {
    var conversationPreviewRowController: UIViewController!

    override func setUp() {
        super.setUp()
        let user = User(id: "test", messagePreview: "Test message.", latestTimestamp: Date.now, read: false, sender: "test", isCustomer: false)
        let conversationPreviewRow = ConversationPreviewRow(user: user)
        conversationPreviewRowController = UIHostingController(rootView: conversationPreviewRow)
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
}

