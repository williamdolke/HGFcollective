//
//  testNotificationSettingsView.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 30/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import HGFcollective

final class testNotificationSettingsView: XCTestCase {
    var notificationSettingsViewController: UIViewController!

    override func setUp() {
        super.setUp()
        let notificationSettingsView = NotificationSettingsView()
        notificationSettingsViewController = UIHostingController(rootView: notificationSettingsView)
    }

    override func tearDown() {
        super.tearDown()
        notificationSettingsViewController = nil
    }

    func testNotificationSettingsViewLight() throws {
        assertSnapshot(
            matching: notificationSettingsViewController,
            as: .image(on: .iPhoneX)
        )
    }

    func testNotificationSettingsViewDark() throws {
        assertSnapshot(
            matching: notificationSettingsViewController,
            as: .image(on: .iPhoneX, traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }
}
