//
//  TestChatView.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 29/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
import AccessibilitySnapshot
@testable import HGFcollective

final class TestChatView: XCTestCase {
    var chatViewController: UIViewController!

    override func setUp() {
        super.setUp()
        let chatView = ChatView()
            .environmentObject(MessagesManager(uid: "test", isCustomer: true))
            .environmentObject(EnquiryManager.shared)
            .environmentObject(TabBarState())
        chatViewController = UIHostingController(rootView: chatView)
        chatViewController.view.frame = UIScreen.main.bounds
    }

    override func tearDown() {
        super.tearDown()
        chatViewController = nil
    }

    func testChatViewLight() throws {
        assertSnapshot(
            matching: chatViewController,
            as: .image(on: .iPhoneX)
        )
    }

    func testChatViewDark() throws {
        assertSnapshot(
            matching: chatViewController,
            as: .image(on: .iPhoneX, traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }

    func testChatViewAccessibility() throws {
        assertSnapshot(
            matching: chatViewController,
            as: .accessibilityImage(showActivationPoints: .always)
        )
    }
}
